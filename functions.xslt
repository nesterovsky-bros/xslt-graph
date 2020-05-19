<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:f="xslt:functions:2020"
  exclude-result-prefixes="xs f">
  
  <!-- A functions API. -->

  <!--
    A while cycle. Calls f:while template.
        
    $state - a while state.
    $condition as function($state as item()*) as xs:boolean - 
      a while condition function.
    $action as function($state as item()*) as item()* - 
      a while action function.
    $next as function($state as item()*, $items as item()*) as item()* - 
      a while next function.
    Returns combined result produced by $action($state) calls.  
  -->
  <xsl:function name="f:while" as="item()*">
    <xsl:param name="state" as="item()*"/>
    <xsl:param name="condition" as="function(item()*) as xs:boolean"/>
    <xsl:param name="action" as="function(item()*) as item()*"/>
    <xsl:param name="next" as="function(item()*, item()*) as item()*"/>

    <xsl:call-template name="f:while">
      <xsl:with-param name="state" select="$state"/>
      <xsl:with-param name="condition" select="$condition"/>
      <xsl:with-param name="action" select="$action"/>
      <xsl:with-param name="next" select="$next"/>
    </xsl:call-template>
  </xsl:function>

  <!--
    A while cycle that returns last state.
    If $condition($state) is true() then
      f:while($condition, $next, $next($state)) is called,
      otherwise $state is returned.
        
    $state - a while state.
    $condition as function($state as item()*) as xs:boolean - 
      a while condition function.
    $next as function($state as item()*) as item()* - 
      a while next function.
    Returns last state.
  -->
  <xsl:function name="f:while" as="item()*">
    <xsl:param name="state" as="item()*"/>
    <xsl:param name="condition" as="function(item()*) as xs:boolean"/>
    <xsl:param name="next" as="function(item()*) as item()*"/>

    <xsl:sequence select="
      if ($condition($state)) then
        f:while($next($state), $condition, $next)
      else
        $state"/>
  </xsl:function>

  <!--
    A repeat cycle. Calls f:repeat template.
        
    $state - a repeat state.
    $condition as function($state as item()*) as xs:boolean - 
      a while condition function.
    $action as function($state as item()*) as item()* - 
      a while action function.
    $next as function($state as item()*, $items as item()*) as item()* - 
      a while next function.
    Returns combined result produced by $action($state) calls.  
  -->
  <xsl:function name="f:repeat" as="item()*">
    <xsl:param name="state" as="item()*"/>
    <xsl:param name="condition" as="function(item()*) as xs:boolean"/>
    <xsl:param name="action" as="function(item()*) as item()*"/>
    <xsl:param name="next" as="function(item()*, item()*) as item()*"/>

    <xsl:call-template name="f:repeat">
      <xsl:with-param name="state" select="$state"/>
      <xsl:with-param name="condition" select="$condition"/>
      <xsl:with-param name="action" select="$action"/>
      <xsl:with-param name="next" select="$next"/>
    </xsl:call-template>
  </xsl:function>

  <!--
    Returns leading subsequence of items in order until 
    a condition is not sutisfied for some item.
      
    $items as item()* - a sequence of items.
    $condition as 
      function($item as item(), $index as xs:integer) as xs:boolean -
      a take condition.
    Returns leading subsequence of items.
  -->
  <xsl:function name="f:take-while" as="item()*">
    <xsl:param name="items" as="item()*"/>
    <xsl:param name="condition" 
      as="function(item(), xs:integer) as xs:boolean"/>

    <xsl:call-template name="f:take-while">
      <xsl:with-param name="items" select="$items"/>
      <xsl:with-param name="condition" select="$condition"/>
    </xsl:call-template>
  </xsl:function>

  <!--
    Returns trailing subsequence of items in order skiping items
    while a condition is sutisfied for items.
      
    $items as item()* - a sequence of items.
    $condition as 
      function($item as item(), $index as xs:integer) as xs:boolean -
      a take condition.
    Returns trailing subsequence of items.
  -->
  <xsl:function name="f:skip-while" as="item()*">
    <xsl:param name="items" as="item()*"/>
    <xsl:param name="condition" 
      as="function(item(), xs:integer) as xs:boolean"/>

    <xsl:call-template name="f:skip-while">
      <xsl:with-param name="items" select="$items"/>
      <xsl:with-param name="condition" select="$condition"/>
    </xsl:call-template>
  </xsl:function>

  <!--
    A while cycle:
      If $condition($state) is true() then
        $action($state) is called to produce a subset of result;
        f:while template is called with state parameter as 
        $next($state, $action($state)).
        
    $state - a while state.
    $condition as function($state as item()*) as xs:boolean - 
      a while condition function.
    $action as function($state as item()*) as item()* - 
      a while action function.
    $next as function($state as item()*, $items as item()*) as item()* - 
      a while next function.
    Returns combined result produced by $action($state) calls.  
  -->
  <xsl:template name="f:while" as="item()*">
    <xsl:param name="state" as="item()*"/>
    <xsl:param name="condition" as="function(item()*) as xs:boolean"/>
    <xsl:param name="action" as="function(item()*) as item()*"/>
    <xsl:param name="next" as="function(item()*, item()*) as item()*"/>

    <xsl:if test="$condition($state)">
      <xsl:variable name="items" as="item()*" select="$action($state)"/>

      <xsl:sequence select="$items"/>

      <xsl:call-template name="f:while">
        <xsl:with-param name="state" select="$next($state, $items)"/>
        <xsl:with-param name="condition" select="$condition"/>
        <xsl:with-param name="action" select="$action"/>
        <xsl:with-param name="next" select="$next"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!--
    A repeat cycle:
      $action($state) is called to produce a subset of result.
      If $condition($state) is false() then
        f:repeat template is called with state parameter as
        $next($state, $action($state)).
        
    $state - a repeat state.
    $condition as function($state as item()*) as xs:boolean - 
      a while condition function.
    $action as function($state as item()*) as item()* - 
      a while action function.
    $next as function($state as item()*, $items as item()*) as item()* - 
      a while next function.
    Returns combined result produced by $action($state) calls.  
  -->
  <xsl:template name="f:repeat" as="item()*">
    <xsl:param name="state" as="item()*"/>
    <xsl:param name="condition" as="function(item()*) as xs:boolean"/>
    <xsl:param name="action" as="function(item()*) as item()*"/>
    <xsl:param name="next" as="function(item()*, item()*) as item()*"/>

    <xsl:variable name="items" as="item()*" select="$action($state)"/>

    <xsl:sequence select="$items"/>

    <xsl:if test="not($condition($state))">
      <xsl:call-template name="f:repeat">
        <xsl:with-param name="state" select="$next($state, $items)"/>
        <xsl:with-param name="condition" select="$condition"/>
        <xsl:with-param name="action" select="$action"/>
        <xsl:with-param name="next" select="$next"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!--
    Returns leading subsequence of items in order until 
    a condition is not sutisfied for some item.
      
    $items as item()* - a sequence of items.
    $condition as 
      function($item as item(), $index as xs:integer) as xs:boolean -
      a take condition.
    $index as xs:integer - current index.
    Returns leading subsequence of items.
  -->
  <xsl:template name="f:take-while" as="item()*">
    <xsl:param name="items" as="item()*"/>
    <xsl:param name="index" as="xs:integer" select="1"/>
    <xsl:param name="condition"
      as="function(item(), xs:integer) as xs:boolean"/>

    <xsl:variable name="item" as="item()?" select="head($items)"/>

    <xsl:if test="exists($item) and $condition($item, $index)">
      <xsl:sequence select="$item"/>

      <xsl:call-template name="f:take-while">
        <xsl:with-param name="items" select="tail($items)"/>
        <xsl:with-param name="index" select="$index + 1"/>
        <xsl:with-param name="condition" select="$condition"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!--
    Returns trailing subsequence of items in order skiping items
    while a condition is sutisfied for items.
      
    $items as item()* - a sequence of items.
    $condition as 
      function($item as item(), $index as xs:integer) as xs:boolean -
      a take condition.
    $index as xs:integer - current index.
    Returns trailing subsequence of items.
  -->
  <xsl:template name="f:skip-while" as="item()*">
    <xsl:param name="items" as="item()*"/>
    <xsl:param name="index" as="xs:integer" select="1"/>
    <xsl:param name="condition"
      as="function(item(), xs:integer) as xs:boolean"/>

    <xsl:variable name="item" as="item()?" select="head($items)"/>
    <xsl:variable name="tail" as="item()*" select="tail($items)"/>

    <xsl:choose>
      <xsl:when test="exists($item) and $condition($item, $index)">
        <xsl:call-template name="f:skip-while">
          <xsl:with-param name="items" select="$tail"/>
          <xsl:with-param name="index" select="$index + 1"/>
          <xsl:with-param name="condition" select="$condition"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$tail"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
