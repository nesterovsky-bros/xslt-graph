<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:g="xslt:graph-api:2020"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  exclude-result-prefixes="xs g map">
  
  <!-- 
    Graph is described with a map of functions, 
    with only two functions required, and others are optional.
    
    Vertex is defined by an atomic value.
    Edge is item()
    
    map
    {
      (: Optional function that returns sequence of vertices. :)
      'vertices': function() as item()*, 
      
      (: Optional function that returns sequence of edges. :)
      'edges': function() as item()*, 
      
      (: Optional function accepting vertex and returning its value. :)
      'vertex-value': function($vertex as item()) as item()*,
      
      (: Optional function accepting edge and returning its value. :)
      'edge-value': function($edge as item()) as item()*
      
      (: Required function returning in and out vertices for an edge. :)
      'edge-vertices': function($edge as item()) as item()+ 
      
      (: Required function returning edges of a vertex. :)
      'vertex-edges': function($vertex as item()) as item()*
    }
  -->

  <!--
    Gets vertices of the graph.
      $g - a graph to get vertices for.
      Returns a sequence of vertices.
  -->
  <xsl:function name="g:vertices" as="item()*">
    <xsl:param name="g" as="map(*)"/>

    <xsl:sequence select="$g?vertices!.()"/>
  </xsl:function>

  <!--
    Gets edges of the graph.
      $g - a graph to get edges for.
      Returns a sequence of edges.
  -->
  <xsl:function name="g:edges" as="item()*">
    <xsl:param name="g" as="map(*)"/>

    <xsl:sequence select="$g?edges!.()"/>
  </xsl:function>

  <!--
    Gets a vertex value.
      $vertex - a vertex.
      $g - a graph to get a vertex value for.
      Returns a vertex value.
  -->
  <xsl:function name="g:vertex-value" as="item()*">
    <xsl:param name="vertex" as="item()"/>
    <xsl:param name="g" as="map(*)"/>
    
    <xsl:sequence select="
      let $fn := $g?vertex-value return
        if (empty($fn)) then
          $vertex
        else
          $fn($vertex)"/>
  </xsl:function>

  <!--
    Gets an edge value.
      $g - a graph to get an edge value for.
      $edge - an edge.
      Returns an edge value.
  -->
  <xsl:function name="g:edge-value" as="item()*">
    <xsl:param name="edge" as="item()"/>
    <xsl:param name="g" as="map(*)"/>

    <xsl:sequence select="
      let $fn := $g?edge-value return
        if (empty($fn)) then
          $edge
        else
          $fn($edge)"/>
  </xsl:function>

  <!--
    Gets an vertices of an edge.
      $g - a graph to get an edge vertices for.
      $edge - an edge.
      Returns an in and out edge vertices.
  -->
  <xsl:function name="g:edge-vertices" as="item()+">
    <xsl:param name="edge" as="item()"/>
    <xsl:param name="g" as="map(*)"/>

    <xsl:sequence select="($g?edge-vertices)($edge)"/>
  </xsl:function>

  <!--
    Gets edges of a vertex.
      $g - a graph to get an edge vertices for.
      $vertex - a vertex.
      Returns an in and out edge vertices.
  -->
  <xsl:function name="g:vertex-edges" as="item()*">
    <xsl:param name="vertex" as="item()"/>
    <xsl:param name="g" as="map(*)"/>

    <xsl:sequence select="($g?vertex-edges)($vertex)"/>
  </xsl:function>

</xsl:stylesheet>
