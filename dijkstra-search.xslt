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

    <xsl:sequence select="
      let $visited := g:dijkstra-search-visited($source, $target, $g) return
        f:while
        (
          function($vertex as item()) { exists($visited($vertex)!?from) },
          function($vertex as item()) { $visited($vertex) },
          function($vertex as item(), $item as map(*)) { $item?from },
          $target
        )"/>
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

    <xsl:sequence select="
      f:while
      (
        function($state as item()*) { q:size($state[2]) > 0 },
        function($state as item()*) 
        {
          let $queue := q:tail($state[2]) return
          let $item := q:head($state[2])?value return
          let $visited := $state[3] return
          let $from := $item?to return
          let $total := $item?distance return
          let $neighbors :=
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
                }
          return
            if ($target = $from) then
              (0, q:create(), $visited)
            else if (empty($neighbors)) then
              $state
            else
              fold-left
              (
                $neighbors,
                (0, $queue, $visited),
                function($state as item()*, $neighbor as map(*)) 
                {
                  let $queue := $state[2] return
                  let $visited := $state[3] return
                  let $to := $neighbor?to return
                  let $distance := $neighbor?distance return
                  let $item := $visited($to) return
                    if (empty($item) or ($distance lt $item?distance)) then
                      (
                        0,
                        q:add($queue, $distance, $to, $neighbor),
                        map:put($visited, $to, $neighbor)
                      )
                    else
                      (0, $queue, $visited)
                }
              )
        },
        let $item := map { 'to': $source } return
          (
            0,
            q:add(q:create(), (), $source, $item),
            map { $source: $item }
          )
      )[3]"/>
  </xsl:function>

</xsl:stylesheet>
