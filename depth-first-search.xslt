<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:g="xslt:graph-api:2020"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  exclude-result-prefixes="xs g map array">

  <!--
    Traverses graph starting from the root vertex.
    See https://en.wikipedia.org/wiki/Depth-first_search.
      
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

    <xsl:sequence select="g:search($root, $g, true())"/>
  </xsl:function>

  <!--
    Traverses graph starting from the root vertex.
    See https://en.wikipedia.org/wiki/Depth-first_search.
      
      $root - a root vertex.
      $g - a graph to traverse.      
      $visitor - a visitor funtion that has following arguments:
        $item as map(*) that defines current item.
          item has following fields.
            from as item() - a vertex traversed from;
            to as item() - a vertex traversed to;
            edge as item() - an edge between vertices;
            depth as xs:integer - a path depth from the root.
        $visited as map(*) - a set of visited vertices.
        $state - current state map;
        Returns new state map.
        If returned state has ?break = true() then the traverse is finished.
      $state - a state.
      Returns last state.
  -->
  <xsl:function name="g:depth-first-search" as="map(*)">
    <xsl:param name="root" as="item()"/>
    <xsl:param name="g" as="map(*)"/>
    <xsl:param name="visitor"
      as="function(map(*), map(*), map(*)) as map(*)"/>
    <xsl:param name="state" as="map(*)"/>

    <xsl:sequence select="g:search($root, $g, true(), $visitor, $state)"/>
  </xsl:function>

</xsl:stylesheet>
