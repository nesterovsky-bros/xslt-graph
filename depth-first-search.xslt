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
    See https://en.wikipedia.org/wiki/Depth-first_search
      $root - a root vertex.
      $g - a graph to traverse.      
      Returns a sequence of maps that describes traversal.
        The map has following fields:
          from as item() - a vertex traversed from;
          to as item()  - a vertex traversed to;
          edge as item()  - an edge between vertices;
          depth as xs:integer - a path depth from the root.
  -->
  <xsl:function name="g:depth-first-search" as="map(*)*">
    <xsl:param name="root" as="item()"/>
    <xsl:param name="g" as="map(*)"/>

    <xsl:sequence select="
      g:depth-first-search
      (
        $root, 
        $g,
        function($item as map(*), $result as array(*)) as array(*)
        {
          array:append($result, $item)
        },
        []
      )?*"/>
  </xsl:function>

  <!--
    Traverses graph starting from the root vertex.
    See https://en.wikipedia.org/wiki/Depth-first_search
      $root - a root vertex.
      $g - a graph to traverse.      
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
  <xsl:function name="g:depth-first-search" as="item()*">
    <xsl:param name="root" as="item()"/>
    <xsl:param name="g" as="map(*)"/>
    <xsl:param name="visitor" 
      as="function(map(*), item()*) as item()*"/>
    <xsl:param name="seed" as="item()*"/>

    <xsl:sequence select="
      p:depth-first-search
      (
        [map { 'to': $root, 'depth': 0 }], 
        $g, 
        $visitor, 
        $seed, 
        map {}
      )"/>
  </xsl:function>

  <!--
    g:depth-first-search() implementation.
      $queue - a queue of items to process.
      $g - a graph to traverse.      
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
  <xsl:function name="p:depth-first-search" as="item()*">
    <xsl:param name="queue" as="array(map(*))"/>
    <xsl:param name="g" as="map(*)"/>
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
          p:depth-first-search
          (
            array:tail($queue), 
            $g, 
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
              array:join
              (
                (
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
                  },
                  array:tail($queue)
                )
              )"/>

            <xsl:sequence select="
              p:depth-first-search
              (
                $new-queue, 
                $g, 
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
