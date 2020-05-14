<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:g="xslt:graph-api:2020"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  xmlns:p="private:xslt:graph-api:2020"
  exclude-result-prefixes="xs g map array p">

  <!--
    Traverses graph starting from the root vertex.
    See https://en.wikipedia.org/wiki/Depth-first_search and
      https://en.wikipedia.org/wiki/Breadth-first_search.
      
      $root - a root vertex.
      $g - a graph to traverse.      
      $is-depth-first - true() for depth first, and 
        false() for breadth first search.
      Returns a sequence of maps that describes traversal.
        The map has following fields:
          from as item() - a vertex traversed from;
          to as item()  - a vertex traversed to;
          edge as item()  - an edge between vertices;
          depth as xs:integer - a path depth from the root.
  -->
  <xsl:function name="g:search" as="map(*)*">
    <xsl:param name="root" as="item()"/>
    <xsl:param name="g" as="map(*)"/>
    <xsl:param name="is-depth-first" as="xs:boolean"/>

    <xsl:sequence select="
      g:search
      (
        $root, 
        $g,
        $is-depth-first,
        function($item as map(*), $result as map(*)*) as map(*)*
        {
          $result, $item
        },
        ()
      )"/>
  </xsl:function>

  <!--
    Traverses graph starting from the root vertex.
    See https://en.wikipedia.org/wiki/Depth-first_search and
      https://en.wikipedia.org/wiki/Breadth-first_search.
      
      $root - a root vertex.
      $g - a graph to traverse.      
      $is-depth-first - true() for depth first, and 
        false() for breadth first search.
      $visitor - a visitor funtion that has following arguments:
        $item as map(*) that defines current item.
          item has following fields.
            from as item() - a vertex traversed from;
            to as item() - a vertex traversed to;
            edge as item() - an edge between vertices;
            depth as xs:integer - a path depth from the root.
        $seed - current seed;
        Returns new seed.
        If returned seed is empty sequence the traverse is finished.
      $seed - a seed item.
      Returns last seed.
  -->
  <xsl:function name="g:search" as="item()*">
    <xsl:param name="root" as="item()"/>
    <xsl:param name="g" as="map(*)"/>
    <xsl:param name="is-depth-first" as="xs:boolean"/>
    <xsl:param name="visitor"
      as="function(map(*), item()*) as item()*"/>
    <xsl:param name="seed" as="item()*"/>

    <xsl:sequence select="
      p:search
      (
        [map { 'to': $root, 'depth': 0 }], 
        $g, 
        $is-depth-first,
        $visitor, 
        $seed, 
        map {}
      )"/>
  </xsl:function>

  <!--
    g:search() implementation.
      $queue - a queue of items to process.
      $g - a graph to traverse.
      $is-depth-first - true() for depth first, and 
        false() for breadth first search.
      $visitor - a visitor funtion that has following arguments:
        $item as map(*) that defines current item.
          item has following fields.
            from as item() - a vertex traversed from;
            to as item() - a vertex traversed to;
            edge as item() - an edge between vertices;
            depth as xs:integer - a path depth from the root.
        $seed - current seed;
        Returns new seed.
        If returned seed is empty sequence the traverse is finished.
      $seed - a seed item.
      $visited - a set of visited vertices.
      Returns last seed.
  -->
  <xsl:function name="p:search" as="item()*">
    <xsl:param name="queue" as="array(map(*))"/>
    <xsl:param name="g" as="map(*)"/>
    <xsl:param name="is-depth-first" as="xs:boolean"/>
    <xsl:param name="visitor"
      as="function(map(*), item()*) as item()*"/>
    <xsl:param name="seed" as="item()*"/>
    <xsl:param name="visited" as="map(*)"/>

    <xsl:variable name="item" as="item()?" select="
      if (array:size($queue) = 0) then
        ()
      else
        array:head($queue)"/>
    
    <xsl:variable name="to" as="item()?" select="$item?to"/>
    
    <xsl:choose>
      <xsl:when test="empty($item)">
        <xsl:sequence select="$seed"/>
      </xsl:when>
      <xsl:when test="$visited($to)">
        <xsl:sequence select="
          p:search
          (
            array:tail($queue), 
            $g,
            $is-depth-first,
            $visitor, 
            $seed, 
            $visited
          )"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="new-seed" as="item()*" 
          select="$visitor($item, $seed)"/>

        <xsl:choose>
          <xsl:when test="empty($new-seed)">
            <xsl:sequence select="$seed"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="new-visited" as="map(*)" 
              select="map:put($visited, $to, true())"/>
            
            <xsl:variable name="new-queue" as="array(map(*))" select="
              let $tail := array:tail($queue) return
              let $new-items :=
                array 
                {
                  for 
                    $edge in g:vertex-edges($to, $g),
                    $vertex in g:edge-vertices($edge, $g)
                  return
                    if ($new-visited($vertex)) then
                      ()
                    else
                      map 
                      { 
                        'from': $to, 
                        'to': $vertex, 
                        'edge': $edge,
                        'depth': $item?depth + 1
                      }
                }
              return
                if ($is-depth-first) then
                  array:join(($new-items, $tail))
                else
                  array:join(($tail, $new-items))"/>

            <xsl:sequence select="
              p:search
              (
                $new-queue, 
                $g,
                $is-depth-first,
                $visitor, 
                $new-seed, 
                $new-visited
              )"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
