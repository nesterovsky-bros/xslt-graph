<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:g="xslt:graph-api:2020"
  xmlns:p="private:xslt:graph-api:2020"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  exclude-result-prefixes="xs g p map array">

  <!--
    An algorithm for finding the shortest paths between vertices in a graph.
    See https://en.wikipedia.org/wiki/Bellman%E2%80%93Ford_algorithm.
      
      $source - a source vertex.
      $check-cycles - true to check cycles, and return 
        empty sequence in case of cycle.
      $g - a graph to traverse.      
      Returns a map of maps per vertices that describes distances and 
      paths to source from all reachable vertices.
        The item map has following fields:
          from as item()? - a vertex traversed from;
          to as item() - a vertex traversed to;
          edge as item()? - an edge between vertices;
          distance as item()? - a path distance from the root, which is
            a sum of edge values.
  -->
  <xsl:function name="g:bellman-ford-search" as="map(*)?">
    <xsl:param name="source" as="item()"/>
    <xsl:param name="check-cycles" as="xs:boolean"/>
    <xsl:param name="g" as="map(*)"/>

    <xsl:sequence select="
      let $result := p:bellman-ford-search($source, $g) return
        $result[1][not($check-cycles) or (map:size($result[2]) = 0)]"/>
  </xsl:function>

  <!--
    An algorithm for finding the shortest paths between vertices in a graph.
    See https://en.wikipedia.org/wiki/bellman-ford%27s_algorithm.
      
      $source - a source vertex.
      $target - a target vertex.
      $check-cycles - true to check cycles, and return 
        empty sequence in case of cycle.
      $g - a graph to traverse.      
      Returns a sequence of maps that describes distances and 
      paths from target to source vertices.
        The map has following fields:
          from as item()? - a vertex traversed from;
          to as item() - a vertex traversed to;
          edge as item()? - an edge between vertices;
          distance as item()? - a path distance from the root, which is
            a sum of edge values.
  -->
  <xsl:function name="g:bellman-ford-search" as="map(*)*">
    <xsl:param name="source" as="item()"/>
    <xsl:param name="target" as="item()"/>
    <xsl:param name="check-cycles" as="xs:boolean"/>
    <xsl:param name="g" as="map(*)"/>

    <xsl:variable name="result" as="item()+" 
      select="p:bellman-ford-search($source, $g)"/>
    <xsl:variable name="visited" as="map(*)" select="$result[1]"/>
    <xsl:variable name="front" as="map(*)" select="$result[2]"/>

    <xsl:iterate select="1 to map:size($visited)">
      <xsl:param name="target" as="item()" select="$target"/>
      <xsl:param name="path" as="map(*)*"/>

      <xsl:variable name="item" as="map(*)?" select="$visited($target)"/>

      <xsl:choose>
        <xsl:when 
          test="empty($item) or ($check-cycles and exists($front($target)))">
          <xsl:break/>
        </xsl:when>
        <xsl:when test="empty($item!?from)">
          <xsl:break select="$path"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:next-iteration>
            <xsl:with-param name="target" select="$item?from"/>
            <xsl:with-param name="path" select="$item, $path"/>
          </xsl:next-iteration>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:iterate>
  </xsl:function>

  <!--
    An algorithm for finding the shortest paths between vertices in a graph.
    See https://en.wikipedia.org/wiki/bellman-ford%27s_algorithm.
      
      $source - a source vertex.
      $g - a graph to traverse.      
      Returns a sequece from two items:
        [1] as map(*) - a maps per vertex that describes 
          distances and paths from source to target vertex.
          The map has following fields:
            from as item()? - a vertex traversed from;
            to as item() - a vertex traversed to;
            edge as item()? - an edge between vertices;
            distance as item()? - a path distance from the root, which is
              a sum of edge values.
        [2] as map(*) - a residue search front set.
  -->
  <xsl:function name="p:bellman-ford-search" as="item()+">
    <xsl:param name="source" as="item()"/>
    <xsl:param name="g" as="map(*)"/>

    <xsl:variable name="item" as="map(*)" select="map { 'to': $source }"/>

    <xsl:iterate select="g:vertices($g)">
      <xsl:param name="visited" as="map(*)" select="map { $source: $item }"/>
      <xsl:param name="front" as="map(*)" select="map { $source: $item} "/>

      <xsl:on-completion select="$visited, $front"/>

      <xsl:choose>
        <xsl:when test="map:size($front) = 0">
          <xsl:break select="$visited, $front"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="next" as="item()+">
            <xsl:iterate select="$front?*">
              <xsl:param name="visited" as="map(*)" select="$visited"/>
              <xsl:param name="front" as="map(*)" select="map {}"/>

              <xsl:on-completion select="$visited, $front"/>

              <xsl:variable name="item" as="map(*)" select="."/>
              <xsl:variable name="from" as="item()" select="$item?to"/>
              <xsl:variable name="total" as="item()?" select="$item?distance"/>

              <xsl:variable name="neighbors" as="map(*)*" select="
                for $edge in g:vertex-edges($from, $g) return
                let $distance := g:edge-value($edge, $g) return
                for $to in g:edge-vertices($edge, $g) return
                  if ($to = $from) then
                    ()
                  else
                    map 
                    { 
                      'from': $from,
                      'to': $to,
                      'edge': $edge,
                      'distance': 
                        if (empty($total)) then
                          $distance
                        else
                          $total + $distance
                    }"/>

              <xsl:variable name="next" as="item()+">
                <xsl:iterate select="$neighbors">
                  <xsl:param name="visited" as="map(*)" select="$visited"/>
                  <xsl:param name="front" as="map(*)" select="$front"/>

                  <xsl:on-completion select="$visited, $front"/>

                  <xsl:variable name="neighbor" as="map(*)" select="."/>
                  <xsl:variable name="to" as="item()" select="$neighbor?to"/>
                  <xsl:variable name="distance" as="item()" select="$neighbor?distance"/>
                  <xsl:variable name="item" as="item()?" select="$visited($to)"/>

                  <xsl:if test="empty($item) or ($distance lt $item?distance)">
                    <xsl:next-iteration>
                      <xsl:with-param name="visited"
                        select="map:put($visited, $to, $neighbor)"/>
                      <xsl:with-param name="front"
                        select="map:put($front, $to, $neighbor)"/>
                    </xsl:next-iteration>
                  </xsl:if>
                </xsl:iterate>
              </xsl:variable>

              <xsl:next-iteration>
                <xsl:with-param name="visited" select="$next[1]"/>
                <xsl:with-param name="front" select="$next[2]"/>
              </xsl:next-iteration>
            </xsl:iterate>  
          </xsl:variable>

          <xsl:next-iteration>
            <xsl:with-param name="visited" select="$next[1]"/>
            <xsl:with-param name="front" select="$next[2]"/>
          </xsl:next-iteration>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:iterate>
  </xsl:function>

</xsl:stylesheet>
