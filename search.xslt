<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:g="xslt:graph-api:2020"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  exclude-result-prefixes="xs g map array">

  <!--
    Traverses graph starting from the root vertex.
    See https://en.wikipedia.org/wiki/Depth-first_search and
      https://en.wikipedia.org/wiki/Breadth-first_search.

      $root - a root vertex.
      $g - a graph to traverse.
      $is-depth-first - true() for depth first, and 
        false() for breadth first search.
      $visited - a set of visited vertices.
      Returns a sequence of maps, where map has following fields:
        from as item()? - optional source vertex.
        to as item() - optional target vertex.
        edge as item()? - optional edge.
        depth as xs:integer - an item depth.
  -->
  <xsl:function name="g:search" as="map(*)*">
    <xsl:param name="root" as="item()"/>
    <xsl:param name="g" as="map(*)"/>
    <xsl:param name="is-depth-first" as="xs:boolean"/>
    <xsl:param name="visited" as="map(*)"/>

    <xsl:iterate select="g:vertices($g)">
      <xsl:param name="queue" as="array(map(*))" 
        select="[ map { 'to': $root, 'depth': 0 } ]"/>
      <xsl:param name="visited" as="map(*)" select="$visited"/>

      <xsl:choose>
        <xsl:when test="array:size($queue) eq 0">
          <xsl:break/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="item" as="item()" select="array:head($queue)"/>
          <xsl:variable name="queue" as="array(map(*))"
            select="array:tail($queue)"/>
          <xsl:variable name="to" as="item()" select="$item?to"/>

          <xsl:choose>
            <xsl:when test="$visited($to)">
              <xsl:next-iteration>
                <xsl:with-param name="queue" select="$queue"/>
              </xsl:next-iteration>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="$item"/>
              
              <xsl:variable name="visited" as="map(*)" 
                select="map:put($visited, $to, true())"/>

              <xsl:variable name="items" as="array(map(*))" select="
                array 
                {
                  for 
                    $edge in g:vertex-edges($to, $g),
                    $vertex in g:edge-vertices($edge, $g)
                  return
                    if ($visited($vertex)) then
                      ()
                    else
                      map 
                      { 
                        'from': $to, 
                        'to': $vertex, 
                        'edge': $edge,
                        'depth': $item?depth + 1
                      }
                }"/>

              <xsl:next-iteration>
                <xsl:with-param name="queue" select="
                  if ($is-depth-first) then
                    array:join(($items, $queue))
                  else
                    array:join(($queue, $items))"/>

                <xsl:with-param name="visited" select="$visited"/>
              </xsl:next-iteration>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:iterate>
  </xsl:function>

</xsl:stylesheet>