<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:q="xslt:priority-queue:2020"
  xmlns:p="private:xslt:priority-queue:2020"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  exclude-result-prefixes="xs map array p">
  
  <!-- A priority queue API. -->

  <!--
    Creates empty priority queue.
      Returns a map representing a priority queue.
  -->
  <xsl:function name="q:create" as="map(*)">
    <xsl:sequence select="map { 'keys': map {}, 'items': [] }"/>
  </xsl:function>

  <!--
    Creates a priority queue adding a value.
      $q - original queue.
      $priority - a value priority.
      $key - a value key.
      $value - a value.
      Returns new queue.
  -->
  <xsl:function name="q:add" as="map(*)">
    <xsl:param name="q" as="map(*)"/>
    <xsl:param name="priority" as="item()?"/>
    <xsl:param name="key" as="item()"/>
    <xsl:param name="value" as="item()*"/>

    <xsl:variable name="keys" as="map(*)" select="$q?keys"/>
    
    <xsl:variable name="items" as="array(*)" select="
      let $items := $q?items return
      let $item := $keys($key) return
        if (exists($item)) then
          let 
            $index := 
              p:search($keys, $items, $item?priority, $key, 1, array:size($items))
          return
            array:remove($items, $index)
        else
          $items"/>
    
    <xsl:variable name="index" as="xs:integer" 
      select="p:search($keys, $items, $priority, $key, 1, array:size($items))"/>

    <xsl:sequence select="
      map
      {
        'keys': 
           map:put
           (
              $keys,
              $key,
              map { 'key': $key, 'priority': $priority, 'value': $value }
           ), 
        'items': array:insert-before($items, -$index, $key)
      }"/>
  </xsl:function>

  <!--
    Creates a priority queue without a value that corresponds to a key.
      $q - original queue.
      $key - a value key.
      Returns new queue.
  -->
  <xsl:function name="q:remove" as="map(*)">
    <xsl:param name="q" as="map(*)"/>
    <xsl:param name="key" as="item()"/>

    <xsl:variable name="keys" as="map(*)" select="$q?keys"/>
    <xsl:variable name="items" as="array(*)" select="$q?items"/>
    <xsl:variable name="item" as="map(*)?" select="$keys($key)"/>

    <xsl:choose>
      <xsl:when test="empty($item)">
        <xsl:sequence select="$q"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="index" as="xs:integer" select="
          p:search($keys, $items, $item?priority, $key, 1, array:size($items))"/>

        <xsl:sequence select="
          map
          {
            'keys': map:remove($keys, $key), 
            'items': array:remove($items, $index)
          }"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Gets a head item of the queue.
      $q - original queue.
      Returns a map with fields:
        'key' as item() - an item key;
        'priority' as item() as item priority;
        'value' as item()* as item value.
  -->
  <xsl:function name="q:head" as="map(*)?">
    <xsl:param name="q" as="map(*)"/>

    <xsl:sequence select="
      let $items := $q?items return
        if (array:size($items) = 0) then
          ()
        else
          array:head($items)!$q?keys(.)"/>
  </xsl:function>

  <!--
    Creates a priority queue without an item with top priority.
      $q - original queue.
      Returns new queue.
  -->
  <xsl:function name="q:tail" as="map(*)">
    <xsl:param name="q" as="map(*)"/>

    <xsl:sequence select="
      let $items := $q?items return
        if (array:size($items) = 0) then
          $q
        else
          map
          {
            'keys': map:remove($q?keys, array:head($items)), 
            'items': array:tail($items)
          }"/>
  </xsl:function>

  <!--
    Gets an item by key.
      $q - original queue.
      $key - a value key.
      Returns a map, if any, with fields:
        'key' as item() - an item key;
        'priority' as item() as item priority;
        'value' as item()* as item value.
  -->
  <xsl:function name="q:item" as="map(*)?">
    <xsl:param name="q" as="map(*)"/>
    <xsl:param name="key" as="item()"/>

    <xsl:sequence select="$q?keys($key)"/>
  </xsl:function>

  <!--
    Gets all items of the queue.
      $q - original queue.
      Returns a sequence of maps with fields:
        'key' as item() - an item key;
        'priority' as item() as item priority;
        'value' as item()* as item value.
  -->
  <xsl:function name="q:items" as="map(*)*">
    <xsl:param name="q" as="map(*)"/>

    <xsl:sequence select="$q?items?*!$q?keys(.)"/>
  </xsl:function>

  <!--
    Searches an item by priority and key using binary search.
      $keys - a map of keys to items.
      $items - an array of items.
      $priority - an item priority.
      $key - an item key.
      $low - a low value of search range (including).
      $low - a high value of search range (including).
      Retuns a found index, of negative value of the closest 
      index before insertion point.
  -->
  <xsl:function name="p:search" as="xs:integer">
    <xsl:param name="keys" as="map(*)"/>
    <xsl:param name="items" as="array(*)"/>
    <xsl:param name="priority" as="item()?"/>
    <xsl:param name="key" as="item()"/>
    <xsl:param name="low" as="xs:integer"/>
    <xsl:param name="high" as="xs:integer"/>

    <xsl:choose>
      <xsl:when test="$low le $high">
        <xsl:variable name="mid" as="xs:integer"
          select="($low + $high) idiv 2"/>
        <xsl:variable name="mid-item" as="map(*)" 
          select="$items($mid)!$keys(.)"/>
        <xsl:variable name="mid-priority" as="item()?" 
          select="$mid-item?priority"/>
        <xsl:variable name="mid-key" as="item()" select="$mid-item?key"/>

        <xsl:choose>
          <xsl:when test="
            ($mid-priority lt $priority) or
            (empty($mid-priority) and exists($priority))">
            <xsl:sequence select="
              p:search($keys, $items, $priority, $key, $mid + 1, $high)"/>
          </xsl:when>
          <xsl:when test="
            ($mid-priority gt $priority) or
            (exists($mid-priority) and empty($priority))">
            <xsl:sequence select="
              p:search($keys, $items, $priority, $key, $low, $mid - 1)"/>
          </xsl:when>
          <xsl:when test="$mid-key lt $key">
            <xsl:sequence select="
              p:search($keys, $items, $priority, $key, $mid + 1, $high)"/>
          </xsl:when>
          <xsl:when test="$mid-key gt $key">
            <xsl:sequence select="
              p:search($keys, $items, $priority, $key, $low, $mid - 1)"/>
          </xsl:when>
          <xsl:otherwise>
            <!-- Key found.-->
            <xsl:sequence select="$mid"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <!-- Key not found.-->
        <xsl:sequence select="-$low"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
