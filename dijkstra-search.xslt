<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:f="xslt:functions:2020"
  xmlns:q="xslt:priority-queue:2020"
  xmlns:g="xslt:graph-api:2020"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  exclude-result-prefixes="xs f q g map array">

  <!--
    An algorithm for finding the shortest paths between nodes in a graph.
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
    An algorithm for finding the shortest paths between nodes in a graph.
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
    An algorithm for finding the shortest paths between nodes in a graph.
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
    An algorithm for finding the shortest paths between nodes in a graph.
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
        function($state as map(*)) { q:size($state?queue) > 0 },
        function($state as map(*)) { $state?visited },
        function($state as map(*), $visited as map(*)) 
        {
          let $visited := $state?visited return
          let $queue := q:tail($state?queue) return
          let $item := q:head($state?queue)?value return
          let $from := $item?to return
          let $from-distance := $item?distance return
          let
            $neighbors :=
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
                  }
          return
            if (exists($target) and ($target = $from)) then
              map { 'queue': q:create(), 'visited': $visited }
            else if (empty($neighbors)) then
              map { 'queue': $queue, 'visited': $visited }
            else
              f:repeat
              (
                function($state as map(*)) { empty($neighbors[$state?index]) },
                function($state as map(*)) { $state },
                function($state as map(*), $result as map(*)) 
                {
                  let $queue := $state?queue return
                  let $visited := $state?visited return
                  let $index := $state?index return
                  let $neighbor := $neighbors[$index] return
                  let $to := $neighbor?to return
                  let $distance := $neighbor?distance return
                  let $item := $visited($to) return
                  if (empty($item) or ($distance lt $item?distance)) then
                      map 
                      { 
                        'index': $index + 1,
                        'queue': q:add($queue, $distance, $to, $neighbor),
                        'visited': map:put($visited, $to, $neighbor)
                      }
                    else
                      map 
                      { 
                        'index': $index + 1,
                        'queue': $queue,
                        'visited': $visited
                      }
                },
                map
                {
                  'index': 1,
                  'queue': $queue, 
                  'visited': $visited
                }
              )[last()]
        },
        let $item := map { 'to': $source } return
          map 
          {
            'queue': q:add(q:create(), (), $source, $item),
            'visited': map { $source: $item }
          }
      )[last()]"/>
  </xsl:function>

</xsl:stylesheet>
