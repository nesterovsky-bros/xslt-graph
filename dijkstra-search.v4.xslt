<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:f="xslt:functions:2020"
  xmlns:q="xslt:priority-queue:2020"
  xmlns:g="xslt:graph-api:2020"
  xmlns:p="private:xslt:graph-api:2020"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  exclude-result-prefixes="xs f q g p map array">

  <!--
    An algorithm for finding the shortest paths between vertices in a graph.
    See https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm.
      
      $source - a source vertex.
      $g - a graph to traverse.      
      Returns a map of maps per vertices that describes distances and 
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

    <xsl:sequence select="g:dijkstra-search-visited($source, (), $g)"/>
  </xsl:function>

  <!--
    An algorithm for finding the shortest paths between vertices in a graph.
    See https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm.
      
      $source - a source vertex.
      $target - a target vertex.
      $g - a graph to traverse.      
      Returns a sequence of maps that describes distances and 
      paths from source to target vertices.
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

    <xsl:sequence 
      select="reverse(g:dijkstra-search-reversed($source, $target, $g))"/>
  </xsl:function>

  <!--
    An algorithm for finding the shortest paths between vertices in a graph.
    See https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm.
      
      $source - a source vertex.
      $target - a target vertex.
      $g - a graph to traverse.      
      Returns a sequence of maps that describes distances and 
      paths from target to source vertices.
        The map has following fields:
          from as item()? - a vertex traversed from;
          to as item() - a vertex traversed to;
          edge as item()? - an edge between vertices;
          distance as item()? - a path distance from the root, which is
            a sum of edge values.
  -->
  <xsl:function name="g:dijkstra-search-reversed" as="map(*)*">
    <xsl:param name="source" as="item()"/>
    <xsl:param name="target" as="item()"/>
    <xsl:param name="g" as="map(*)"/>

    <xsl:variable name="visited" as="map(*)" 
      select="g:dijkstra-search-visited($source, $target, $g)"/>

    <xsl:iterate select="1 to map:size($visited)">
      <xsl:param name="target" as="item()" select="$target"/>

      <xsl:variable name="item" as="map(*)?" select="$visited($target)"/>

      <xsl:choose>
        <xsl:when test="empty($item!?from)">
          <xsl:break/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$item"/>

          <xsl:next-iteration>
            <xsl:with-param name="target" select="$item?from"/>
          </xsl:next-iteration>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:iterate>
  </xsl:function>

  <!--
    An algorithm for finding the shortest paths between vertices in a graph.
    See https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm.
      
      $source - a source vertex.
      $target - optional target vertex.
      $g - a graph to traverse.      
      Returns a map of maps per vertex that describes distances and paths 
      from source to target vertex.
        The map has following fields:
          from as item()? - a vertex traversed from;
          to as item() - a vertex traversed to;
          edge as item()? - an edge between vertices;
          distance as item()? - a path distance from the root, which is
            a sum of edge values.
  -->
  <xsl:function name="g:dijkstra-search-visited" as="map(*)">
    <xsl:param name="source" as="item()"/>
    <xsl:param name="target" as="item()?"/>
    <xsl:param name="g" as="map(*)"/>

    <xsl:variable name="item" as="map(*)" select="map { 'to': $source }"/>

    <xsl:iterate select="g:vertices($g)">
      <xsl:param name="queue" as="map(*)"
        select="q:add(q:create(), (), $source, $item)"/>
      <xsl:param name="visited" as="map(*)"
        select="map { $source: $item }"/>

      <xsl:on-completion select="$visited"/>

      <xsl:choose>
        <xsl:when test="q:size($queue) = 0">
          <xsl:break select="$visited"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="item" as="map(*)" select="q:head($queue)?value"/>
          <xsl:variable name="queue" as="map(*)" select="q:tail($queue)"/>
          <xsl:variable name="from" as="item()" select="$item?to"/>
          <xsl:variable name="total" as="item()?" select="$item?distance"/>

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
                    if (empty($total)) then
                      $distance
                    else
                      $total + $distance
                }"/>

          <xsl:choose>
            <xsl:when test="$target = $from">
              <xsl:break select="$visited"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="next" as="item()*">
                <xsl:iterate select="$neighbors">
                  <xsl:param name="queue" as="map(*)" select="$queue"/>
                  <xsl:param name="visited" as="map(*)" select="$visited"/>

                  <xsl:on-completion select="$queue, $visited"/>

                  <xsl:variable name="neighbor" as="map(*)" select="."/>
                  <xsl:variable name="to" as="item()" select="$neighbor?to"/>
                  <xsl:variable name="distance" as="item()" select="$neighbor?distance"/>
                  <xsl:variable name="item" as="item()?" select="$visited($to)"/>

                  <xsl:choose>
                    <xsl:when test="empty($item) or ($distance lt $item?distance)">
                      <xsl:next-iteration>
                        <xsl:with-param name="queue"
                          select="q:add($queue, $distance, $to, $neighbor)"/>
                        <xsl:with-param name="visited"
                          select="map:put($visited, $to, $neighbor)"/>
                      </xsl:next-iteration>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:next-iteration/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:iterate>
              </xsl:variable>

              <xsl:next-iteration>
                <xsl:with-param name="queue" select="$next[1]"/>
                <xsl:with-param name="visited" select="$next[2]"/>
              </xsl:next-iteration>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:iterate>
  </xsl:function>

</xsl:stylesheet>
