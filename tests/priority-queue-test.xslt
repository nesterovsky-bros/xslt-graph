<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:q="xslt:priority-queue:2020"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  xmlns:t="public:this"
  exclude-result-prefixes="xs q map array t">

  <xsl:import href="../priority-queue.xslt"/>

  <xsl:template match="/">
    <xsl:variable name="item" as="map(*)?" select="
      q:create()!t:print-queue(.)!
      q:add(., 1, 'A', 'value 1')!t:print-queue(.)!
      q:add(., 2, 'B', 'value 2')!t:print-queue(.)!
      q:add(., 3, 'C', 'value 3')!t:print-queue(.)!
      q:remove(., 'B')!t:print-queue(.)!
      q:add(., 0, '-', 'value 0')!t:print-queue(.)!
      q:tail(.)!t:print-queue(.)!
      q:head(.)   "/>

    <xsl:message>
      <xsl:text>
Head
</xsl:text>

      <xsl:value-of separator=""
        select="$item!(?priority, ' - ', ?key, ': ', ?value)"/>
    </xsl:message>
  </xsl:template>

  <xsl:function name="t:print-queue" as="map(*)">
    <xsl:param name="q" as="map(*)"/>

    <xsl:message>
      <xsl:text>
Queue:
</xsl:text>
      <xsl:for-each select="q:items($q)">
        <xsl:value-of separator="" 
          select="?priority, ' - ', ?key, ': ', ?value"/>
        
        <xsl:text>
</xsl:text>
      </xsl:for-each>
    </xsl:message>

    <xsl:sequence select="$q"/>
  </xsl:function>

</xsl:stylesheet>
