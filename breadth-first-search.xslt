<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:g="xslt:graph-api:2020"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  exclude-result-prefixes="xs g map array">

  <!--
    Traverses graph starting from the root vertex.
    See https://en.wikipedia.org/wiki/Breadth-first_search.
      
      $root - a root vertex.
      $g - a graph to traverse.      
      Returns a sequence of maps that describes traversal.
        The map has following fields:
          from as item() - a vertex traversed from;
          to as item()  - a vertex traversed to;
          edge as item()  - an edge between vertices;
          depth as xs:integer - a path depth from the root.
  -->
  <xsl:function name="g:breadth-first-search" as="map(*)*">
    <xsl:param name="root" as="item()"/>
    <xsl:param name="g" as="map(*)"/>

    <xsl:sequence select="g:search($root, $g, false(), map {})"/>
  </xsl:function>

</xsl:stylesheet>
