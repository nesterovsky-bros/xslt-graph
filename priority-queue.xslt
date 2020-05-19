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
    Empty priority queue.
  -->
  <xsl:variable name="q:empty" as="map(*)"
    select="map { 'keys': map {}, 'items': [] }"/>

  <!--
    Create an empty priority queue.
      Returns a map representing a priority queue.
  -->
  <xsl:function name="q:create" as="map(*)">
    <xsl:sequence select="$q:empty"/>
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

    <xsl:sequence select="
      let $keys := $q?keys return
      let $items := $q?items return
      let $item := $keys($key) return
      let $items :=
        if (empty($item)) then
          $items
        else
          array:remove($items, p:find($keys, $items, $item?priority, $key))
      return
      let $index := p:find($keys, $items, $priority, $key) return
      let $item :=
        map { 'key': $key, 'priority': $priority, 'value': $value } 
      return
        map
        {
          'keys': map:put($keys, $key, $item), 
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

    <xsl:sequence select="
      let $keys := $q?keys return
      let $items := $q?items return
      let $item := $keys($key) return
        if (empty($item)) then
          $q
        else
          map
          {
            'keys': map:remove($keys, $key), 
            'items': 
              array:remove($items, p:find($keys, $items, $item?priority, $key))
          }"/>
  </xsl:function>

  <!--
    Gets size of queue.
      $q - a queue.
      Returns a size of queue.
  -->
  <xsl:function name="q:size" as="xs:integer">
    <xsl:param name="q" as="map(*)"/>

    <xsl:sequence select="array:size($q?items)"/>
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

    <xsl:sequence select="array:head($q?items)!$q?keys(.)"/>
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
      Retuns a found index, of negative value of the closest 
      index before insertion point.
  -->
  <xsl:function name="p:find" as="xs:integer">
    <xsl:param name="keys" as="map(*)"/>
    <xsl:param name="items" as="array(*)"/>
    <xsl:param name="priority" as="item()?"/>
    <xsl:param name="key" as="item()"/>

    <xsl:sequence 
      select="p:find($keys, $items, $priority, $key, 1, array:size($items))"/>
  </xsl:function>

  <!--
    Searches an item by priority and key using binary search.
      $keys - a map of keys to items.
      $items - an array of items.
      $priority - an item priority.
      $key - an item key.
      $low - a low value of search range (including).
      $high - a high value of search range (including).
      Retuns a found index, of negative value of the closest 
      index before insertion point.
  -->
  <xsl:function name="p:find" as="xs:integer">
    <xsl:param name="keys" as="map(*)"/>
    <xsl:param name="items" as="array(*)"/>
    <xsl:param name="priority" as="item()?"/>
    <xsl:param name="key" as="item()"/>
    <xsl:param name="low" as="xs:integer"/>
    <xsl:param name="high" as="xs:integer"/>

    <xsl:sequence select="
      if ($low gt $high) then
        (: Key not found. :)
        -$low
      else
        let $mid := ($low + $high) idiv 2 return
        let $mid-item := $items($mid)!$keys(.) return
        let $mid-priority := $mid-item?priority return
        let $mid-key := $mid-item?key return
          if 
          (
            ($mid-priority lt $priority) or
            (empty($mid-priority) and exists($priority))
          )
          then
            p:find($keys, $items, $priority, $key, $mid + 1, $high)
          else if
          (
            ($mid-priority gt $priority) or
            (exists($mid-priority) and empty($priority))
          )
          then
            p:find($keys, $items, $priority, $key, $low, $mid - 1)
          else if ($mid-key lt $key) then
            p:find($keys, $items, $priority, $key, $mid + 1, $high)
          else if ($mid-key gt $key) then
            p:find($keys, $items, $priority, $key, $low, $mid - 1)
          else
            (: Key found. :)
            $mid"/>
  </xsl:function>

</xsl:stylesheet>
