<?xml version="1.0" encoding="utf-8" standalone="yes"?>

<xsl:transform version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:yz="http://www.hegny.de/xxyy" 
    xmlns:exsl="http://exslt.org/common" 
    xmlns:fx="http://exslt.org/functions" 
    extension-element-prefixes="fx exsl">


<xsl:output method="text"/>

<!-- Mit Startzeit hhmmss wird nur die Beschreibung der zu diesem  -->
<!-- Zeitpunkt startenden Sendung ausgegeben -->
<!-- With given start time (startzeit) (hhmmss) only the description -->
<!-- of the programme starting at that time is shown --> 
<xsl:param name="startzeit" select="''"/>

<!-- Spalten / columns -->
<xsl:param name="cols" select="74"/>

<!-- am Ende vom Sendernamen abzuschneidende Zeichenketten -->
<!-- (von lang nach kurz) -->
<xsl:variable name="trimStationSuffixes">
    <s>.daserste.de</s>
    <s>.de</s>
</xsl:variable>

<xsl:template match="/">
    <xsl:choose>
        <xsl:when test="'' = $startzeit">
            <xsl:apply-templates select="tv/programme">
                <xsl:sort select="@start"/>
            </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
            <xsl:apply-templates select="tv/programme[substring(@start,9,6) = $startzeit]">
                <xsl:with-param name="limited" select="1"/>
            </xsl:apply-templates>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="programme">
    <xsl:param name="limited" select="0"/>
    <xsl:variable name="yy1" select="substring(@start,1,4)"/>
    <xsl:variable name="mo1" select="substring(@stop,5,2)"/>
    <xsl:variable name="dd1" select="substring(@start,7,2)"/>
    <xsl:variable name="hh1" select="substring(@start,9,2)"/>
    <xsl:variable name="mi1" select="substring(@start,11,2)"/>
    <xsl:variable name="ss1" select="substring(@start,13,2)"/>
    <xsl:variable name="hh2" select="substring(@stop,9,2)"/>
    <xsl:variable name="mi2" select="substring(@stop,11,2)"/>
    <xsl:variable name="ss2" select="substring(@stop,13,2)"/>
    <xsl:variable name="st1" select="3600*$hh1 + 60*$mi1 + $ss1"/>
    <xsl:variable name="st2" select="3600*$hh2 + 60*$mi2 + $ss2"/>
    <xsl:variable name="dur">
        <xsl:choose>
            <xsl:when test="$st2 &lt; $st1">
                <xsl:value-of select="(86400 + $st2 - $st1) div 60"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="($st2 - $st1) div 60"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:if test="$limited != 1">
        <xsl:text>&#xa;-------------------------------------------&#xa;</xsl:text>
        <xsl:value-of select="concat('(',$dd1,')  ',$hh1,':',$mi1,':',$ss1,'  +',yz:format3($dur),'   ',yz:printchan(@channel),'   ',title, yz:printsub(.),' - ',yz:print-genres(.),'  ',yz:printyear(.),'&#xa;')"/>
        <xsl:apply-templates select="*[name() != 'sub-title' and name() != 'title']"/>
    </xsl:if>
    <xsl:if test="$limited = 1">
        <xsl:apply-templates select="desc|credits"/>
        <xsl:apply-templates select="date" mode="onlyone"/>
    </xsl:if>
</xsl:template>

<fx:function name="yz:format3">
    <xsl:param name="x"/>
    <xsl:choose>
        <xsl:when test="$x &lt; 10">
            <fx:result select="concat('00',$x)"/>
        </xsl:when>
        <xsl:when test="$x &lt; 100">
            <fx:result select="concat('0',$x)"/>
        </xsl:when>
        <xsl:otherwise>
            <fx:result select="$x"/>
        </xsl:otherwise>
    </xsl:choose>
</fx:function>

<fx:function name="yz:print-genres">
    <xsl:param name="prog"/>
    <xsl:variable name="genlist">
        <xsl:value-of select="$prog/category[1]"/>
        <xsl:for-each select="$prog/category[position() &gt; 1]">
            <xsl:value-of select="concat(', ',.)"/>
        </xsl:for-each>
    </xsl:variable>
    <fx:result select="$genlist"/>
</fx:function>

<fx:function name="yz:printsub">
    <xsl:param name="prog"/>
    <xsl:choose>
        <xsl:when test="'' != $prog/sub-title">
            <fx:result select="concat(' [',sub-title,']')"/>
        </xsl:when>
        <xsl:otherwise>
            <fx:result select="' '"/>
        </xsl:otherwise>
    </xsl:choose>
</fx:function>

<fx:function name="yz:breaktext">
    <xsl:param name="dertextx"/>
    <xsl:param name="breaklen"/>
    <xsl:param name="internda" select="0"/>
    <xsl:variable name="dertext">
    <!-- normalize if no linebreak -->
        <xsl:choose>
            <xsl:when test="contains($dertextx,'&#xa;')">
                <xsl:value-of select="$dertextx"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="normalize-space($dertextx)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="t1x" select="substring-before($dertext,' ')"/>
    <xsl:variable name="t1y" select="substring-before($dertext,'-')"/>
    <xsl:variable name="t1l">
        <xsl:choose>
            <xsl:when test="string-length($t1x) &gt; 0 and string-length($t1x) &lt; string-length($t1y)">
                <xsl:value-of select="string-length($t1x)"/>
            </xsl:when>
            <xsl:when test="0 = string-length($t1y)">
                <xsl:value-of select="string-length($t1x)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="string-length($t1y)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <!-- xsl:message><xsl:value-of select="concat('&#xa;@',$dertext,'@&#xa;T1X: @',$t1x,'@&#xa;T1Y: @',$t1y,'@&#xa;T1L: ',$t1l,'&#xa;INTERNDA: ',$internda,'&#xa;')"/></xsl:message -->
    <!-- xsl:message><xsl:value-of select="concat('&#xa;T1X: @',$t1x,'@&#xa;T1Y: @',$t1y,'@&#xa;T1L: ',$t1l,'&#xa;INTERNDA: ',$internda,'&#xa;')"/></xsl:message -->
    <xsl:choose>
    <!-- abbruch -->
        <xsl:when test="0 = string-length($dertext)"/>
        <xsl:when test="starts-with($dertext,' ')">
        <!-- skip leading space once -->
            <xsl:choose>
                <xsl:when test="' ' = substring($dertext,2,1)">
                    <fx:result select="yz:breaktext(substring($dertext,2),$breaklen,$internda)"/>
                </xsl:when>
                <xsl:otherwise>
                    <fx:result select="concat(' ',yz:breaktext(substring($dertext,2),$breaklen,$internda + 1))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:when test="starts-with($dertext,' ') or starts-with($dertext, '&#xa;')">
            <!-- skip leading nl -->
            <fx:result select="yz:breaktext(substring($dertext,2),$breaklen,$internda)"/>
        </xsl:when>
        <!-- xsl:when test="starts-with($dertext,'-')">
            <!- - special - ->
            <fx:result select="concat('-',yz:breaktext(substring($dertext,2),$breaklen,$internda + 1))"/>
        </xsl:when -->
        <xsl:when test="contains($dertext,'&#xa;')">
        <!-- besser rekursion mit break at newlines -->
            <fx:result select="concat(yz:breaktext(substring-before($dertext,'&#xa;'),$breaklen,$internda),'&#xa;',yz:breaktext(substring-after($dertext,'&#xa;'),$breaklen))"/>
        </xsl:when>
        <xsl:when test="$t1l &gt; 0 and $internda + 1 + $t1l &lt; $breaklen and $t1l = string-length($t1y)">
        <!-- mit hyphen und passt rein bis hyphen -->
            <fx:result select="concat($t1y,'-',yz:breaktext(substring-after($dertext,'-'),$breaklen, $internda + $t1l + 1))"/>
        </xsl:when>
        <xsl:when test="$t1l &gt; 0 and $t1l = string-length($t1y)">
        <!-- mit hyphen passt aber nicht mehr rein -->
            <fx:result select="concat('&#xa;',yz:breaktext($dertext,$breaklen))"/>
        </xsl:when>
        <xsl:when test="$t1l &gt; 0 and $internda + 1 + $t1l &lt; $breaklen">
        <!-- mit space und passt rein bis erstes wort -->
            <fx:result select="concat($t1x,' ',yz:breaktext(substring-after($dertext,' '),$breaklen, $internda + 1 + $t1l))"/>
        </xsl:when>
        <xsl:when test="$internda + string-length($dertext) &lt; $breaklen">
        <!-- ohne linebreak oder space, und passt rein  -->
            <fx:result select="$dertext"/>
        </xsl:when>
        <xsl:otherwise>
        <!-- ohne linebreak, erstes wort passt nicht mehr -->
            <fx:result select="concat('&#xa;',yz:breaktext($dertext,$breaklen))"/>
        </xsl:otherwise>
    </xsl:choose>
</fx:function>

<fx:function name="yz:printyear">
    <xsl:param name="prog"/>
    <xsl:variable name="r">
    <xsl:choose>
        <xsl:when test="'' != $prog/date">
            <!--fx:result select="$prog/date"/-->
            <xsl:value-of select="concat('(',$prog/date,')')"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="' '"/>
        </xsl:otherwise>
    </xsl:choose>
    </xsl:variable>
    <fx:result select="$r"/>
</fx:function>

<xsl:variable name="trimStationSuffixes0" select="exsl:node-set($trimStationSuffixes)"/>
<fx:function name="yz:printchan">
    <xsl:param name="chan"/>
    <xsl:variable name="xc">
        <xsl:choose>
            <xsl:when test="$trimStationSuffixes0/s[substring($chan,string-length($chan) + 1 - string-length(.)) = .]">
                <xsl:value-of select="substring-before($chan, $trimStationSuffixes0/s[substring($chan,string-length($chan) + 1 - string-length(.)) = .][1])"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$chan"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <fx:result select="concat($xc,substring('         ',string-length($xc)))"/>
</fx:function>

<xsl:template match="*">
    <xsl:value-of select="concat('&#xa;', local-name(), ': ', .)"/>
    <xsl:for-each select="@*">
        <xsl:value-of select="concat('&#xa;  @', local-name(), ': ', .)"/>
    </xsl:for-each>
</xsl:template>

<xsl:template match="desc">
    <xsl:variable name="dx" select="normalize-space(.)"/>
    <xsl:if test="$startzeit = ''">
        <xsl:value-of select="'&#xa;&#xa;'"/>
    </xsl:if>
    <xsl:value-of select="concat(yz:breaktext(., $cols),'&#xa;')"/>
</xsl:template>

<xsl:template match="date" mode="onlyone">
    <xsl:variable name="dx" select="normalize-space(.)"/>
    <xsl:value-of select="concat('(',$dx,')&#xa;')"/>
</xsl:template>

<xsl:template match="credits">
    <xsl:text>&#xa;&#xa;Stab/Besetzung:</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&#xa;</xsl:text>
</xsl:template>

<!-- 
tv programme credits actor ... 
tv programme credits actor 00role ... 
tv programme credits director ... 
tv programme credits presenter ... 
tv programme credits producer ... 
tv programme credits writer ... 
-->
<xsl:template match="credits/*[local-name() != 'actor']">
    <xsl:value-of select="concat('&#xa;',local-name(),': ', normalize-space(.))"/>
</xsl:template>
<xsl:template match="credits/actor[not(@role)]">
    <xsl:value-of select="concat('&#xa;+: ', .)"/>
</xsl:template>
<xsl:template match="credits/actor[@role]">
    <xsl:value-of select="concat('&#xa;', @role,' - ', .)"/>
</xsl:template>

<xsl:template match="text()"/>

</xsl:transform>

