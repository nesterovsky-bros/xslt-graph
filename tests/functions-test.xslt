<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:f="xslt:functions:2020"
  xmlns:t="public:this"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  exclude-result-prefixes="xs f t map array">

  <xsl:import href="../functions.xslt"/>

  <xsl:template match="/">
    <xsl:variable name="items" as="xs:integer*" select="
      f:while
      (
        function($index as xs:integer) { $index le 100000 },
        function($index as xs:integer) { $index },
        function($index as xs:integer, $item as xs:integer) { $index + 1 },
        1
      )"/>

    <xsl:message select="$items"/>

    <xsl:variable name="sum" as="xs:integer" select="
      f:while
      (
        function($state as map(*)) { $state?index le 100000 },
        function($state as map(*)) { $state?sum },
        function($state as map(*), $sum as xs:integer) 
        { 
          map 
          { 
            'index': $state?index + 1, 
            'sum': $state?sum + $state?index
          } 
        },
        map { 'index': 1, 'sum': 0 }
      )[last()]"/>

    <xsl:message select="$sum"/>
  </xsl:template>

</xsl:stylesheet>
