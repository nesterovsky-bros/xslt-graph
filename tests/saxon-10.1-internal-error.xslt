<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  exclude-result-prefixes="xs array">

  <xsl:template match="/">
    <xsl:sequence select="
      array:fold-left
      (
        [8, 9], 
        (), 
        function($first as item(), $second as item()) 
        {  
          min(($first, $second))
        }
      )"/>
  </xsl:template>

</xsl:stylesheet>
