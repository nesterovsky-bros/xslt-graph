<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:g="xslt:graph-api:2020"
  xmlns:q="xslt:priority-queue:2020"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  exclude-result-prefixes="xs g q map array">

  <!--
    An algorithm for finding the shortest paths between nodes in a graph.
    See https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm.
      
      $source - a source vertex.
      $g - a graph to traverse.      
      Returns a map of maps that describes distances and 
      paths to source from all reachable vertices.
        The item map has following fields:
          from as item()? - a vertex traversed from;
          to as item() - a vertex traversed to;
          edge as item()? - an edge between vertices;
          distance as item()? - a path distance from the root, which is
            a sum of edge values.
  -->
  <xsl:function name="g:dijkstra-search" as="map(*)">
    <xsl:param name="source" as="item()"/>
    <xsl:param name="g" as="map(*)"/>

    <xsl:sequence select="
      g:dijkstra-search
      (
        $source,
        $g,
        function($item as map(*), $visited as map(*), $state as map(*))
          as map(*)
        {
          map:put($state, $item?to, $item)
        },
        map {}
      )"/>
  </xsl:function>

  <!--
    An algorithm for finding the shortest paths between nodes in a graph.
    See https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm.
      
      $source - a source vertex.
      $target - a target vertex.
      $g - a graph to traverse.      
      Returns a sequence of maps that describes distances and 
      paths from source to target vertex.
        The map has following fields:
          from as item()? - a vertex traversed from;
          to as item() - a vertex traversed to;
          edge as item()? - an edge between vertices;
          distance as item()? - a path distance from the root, which is
            a sum of edge values.
  -->
  <xsl:function name="g:dijkstra-search" as="map(*)*">
    <xsl:param name="source" as="item()"/>
    <xsl:param name="target" as="item()"/>
    <xsl:param name="g" as="map(*)"/>

    <xsl:variable name="result" as="map(*)" select="
      g:dijkstra-search
      (
        $source,
        $g,
        function($item as map(*), $visited as map(*), $state as map(*))
          as map(*)
        {
          map
          {
            'result': map:put($state?result, $item?to, $item),
            'break': $item?to = $target
          }
        },
        map { 'result': map {} }
      )?result"/>

    <xsl:iterate select="1 to map:size($result)">
      <xsl:param name="vertex" as="item()" select="$target"/>
      <xsl:param name="path" as="map(*)*"/>

      <xsl:variable name="item" as="map(*)?" select="$result($vertex)"/>

      <xsl:choose>
        <xsl:when test="empty($item)">
          <xsl:break/>
        </xsl:when>
        <xsl:when test="$vertex = $source">
          <xsl:break select="$path"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:next-iteration>
            <xsl:with-param name="vertex" select="$item?from"/>
            <xsl:with-param name="path" select="$item, $path"/>
          </xsl:next-iteration>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:iterate>
  </xsl:function>

  <!--
    An algorithm for finding the shortest paths between nodes in a graph.
    See https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm.
      
      $source - a source vertex.
      $g - a graph to traverse.      
      $visitor - a visitor funtion that has following arguments:
        $item as map(*) that defines current item.
          item has following fields.
            from as item()? - a vertex traversed from;
            to as item() - a vertex traversed to;
            edge as item()? - an edge between vertices;
            distance as item()? - a path distance from the root, which is
              a sum of edge values.
        $visited map(map(*)) - a map of items per visited vertices.
        $state - current state;
        Returns new state.
        If returned state has ?break = true() then the traverse is finished.
      $state - a state.
      Returns last state.
  -->
  <xsl:function name="g:dijkstra-search" as="map(*)">
    <xsl:param name="source" as="item()"/>
    <xsl:param name="g" as="map(*)"/>
    <xsl:param name="visitor"
      as="function(map(*), map(*), map(*)) as map(*)"/>
    <xsl:param name="state" as="map(*)"/>

    <xsl:variable name="item" as="map(*)" select="map { 'to': $source }"/>

    <xsl:sequence select="
      g:dijkstra-search
      (
        q:add(q:create(), (), $source, $item),
        $g,
        $visitor,
        $state,
        map { $source: $item }
      )"/>
  </xsl:function>

  <!--
    An algorithm for finding the shortest paths between nodes in a graph.
    See https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm.
      
      $queue - a priority queue of vertices using distance as priority.
      $g - a graph to traverse.      
      $visitor - a visitor funtion that has following arguments:
        $item as map(*) that defines current item.
          item has following fields.
            from as item()? - a vertex traversed from;
            to as item() - a vertex traversed to;
            edge as item()? - an edge between vertices;
            distance as item()? - a path distance from the root, which is
              a sum of edge values.
        $visited map(map(*)) - a map of items per visited vertices.
        $state - current state;
        Returns new state.
        If returned state has ?break = true() then the traverse is finished.
      $state - a state map.
      $visited - a visited items per vertices.
      Returns last state.
  -->
  <xsl:function name="g:dijkstra-search" as="map(*)">
    <xsl:param name="queue" as="map(*)"/>
    <xsl:param name="g" as="map(*)"/>
    <xsl:param name="visitor"
      as="function(map(*), map(*), map(*)) as map(*)"/>
    <xsl:param name="state" as="map(*)"/>
    <xsl:param name="visited" as="map(*)"/>

    <xsl:variable name="item" as="map(*)?" select="q:head($queue)?value"/>

    <xsl:choose>
      <xsl:when test="empty($item)">
        <xsl:sequence select="$state"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="new-state" as="map(*)"
          select="$visitor($item, $visited, $state)"/>

        <xsl:choose>
          <xsl:when test="xs:boolean($new-state?break)">
            <xsl:sequence select="$new-state"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="from" as="item()" select="$item?to"/>
            <xsl:variable name="from-distance" as="item()?" 
              select="$item?distance"/>

            <xsl:variable name="neighbors" as="map(*)*" select="
              for $edge in g:vertex-edges($from, $g) return
              let $distance := g:edge-value($edge, $g) return
              for $to in g:edge-vertices($edge, $g) return
                if ($to = $from) then
                  ()
                else
                  map 
                  { 
                    'from': $from,
                    'to': $to,
                    'edge': $edge,
                    'distance': 
                       if (empty($from-distance)) then
                         $distance
                       else
                         $from-distance + $distance
                  }"/>

            <xsl:variable name="next" as="map(*)">
              <xsl:iterate select="$neighbors">
                <xsl:param name="param" as="map(*)" 
                  select="map { 'queue': q:tail($queue), 'visited': $visited }"/>
                           
                <xsl:on-completion select="$param"/>

                <xsl:next-iteration>
                  <xsl:with-param name="param" select="
                    let $to := ?to return
                    let $distance := ?distance return
                    let $visited-item := $visited($to) return
                      if (empty($visited-item)) then
                        map 
                        { 
                          'queue': q:add($param?queue, $distance, $to, .),
                          'visited': map:put($param?visited, $to, .)
                        }
                      else if ($distance lt $visited-item?distance) then
                        map 
                        { 
                          'queue': q:add($param?queue, $distance, $to, .),
                          'visited': $param?visited
                        }
                      else
                        $param"/>
                </xsl:next-iteration>
              </xsl:iterate>
            </xsl:variable>

            <xsl:sequence select="
              g:dijkstra-search
              (
                $next?queue,
                $g,
                $visitor,
                $new-state,
                $next?visited
              )"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
