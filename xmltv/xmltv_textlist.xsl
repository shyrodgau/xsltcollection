<?xml version="1.0" encoding="utf-8" standalone="yes"?>

<xsl:transform version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:zz="http://www.hegny.de/xxyy" 
    xmlns:exsl="http://exslt.org/common"
    xmlns:fx="http://exslt.org/functions"
    extension-element-prefixes="fx exsl">
    

<xsl:output method="text"/>

<!-- am Ende vom Sendernamen abzuschneidende Zeichenketten -->
<!-- (von lang nach kurz) -->
<xsl:variable name="trimStationSuffixes">
    <s>.daserste.de</s>
    <s>.de</s>
</xsl:variable>

<xsl:template match="/">
    <xsl:apply-templates select=".//programme">
        <xsl:sort select="@start"/>
    </xsl:apply-templates>
</xsl:template>

<xsl:template match="programme">
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
    <xsl:value-of select="concat('(',$dd1,')  ',$hh1,':',$mi1,':',$ss1,'  +',zz:format3($dur),'   ',zz:printchan(@channel),'   ',title, zz:printsub(.),' - ',zz:print-genres(.),'  ',zz:printyear(.),'&#xa;')"/>
</xsl:template>

<fx:function name="zz:format3">
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

<fx:function name="zz:print-genres">
    <xsl:param name="prog"/>
    <xsl:variable name="genlist">
        <xsl:value-of select="$prog/category[1]"/>
        <xsl:for-each select="$prog/category[position() &gt; 1]">
            <xsl:value-of select="concat(', ',.)"/>
        </xsl:for-each>
    </xsl:variable>
    <fx:result select="$genlist"/>
</fx:function>

<fx:function name="zz:printsub">
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

<fx:function name="zz:printyear">
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
<fx:function name="zz:printchan">
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

</xsl:transform>

