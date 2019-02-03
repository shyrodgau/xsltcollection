<?xml version="1.0" encoding="utf-8" standalone="yes"?>

<xsl:transform version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ex="http://exslt.org/common"
    extension-element-prefixes="ex">

    <xsl:variable name="firstdocname" select="(//f)[1]"/>
    <xsl:variable name="firstdoc" select="document($firstdocname)"/>
    <xsl:param name="date" select="substring(($firstdoc//*[local-name() = 'trkpt'])[1]/*[local-name() = 'time'],1,10)"/>
    
    <xsl:variable name="all0">
        <xsl:for-each select="//f">
            <xsl:copy-of select="document(.)"/>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:variable name="all" select="ex:node-set($all0)"/>
 
    <xsl:variable name="allsort0">
        <xsl:for-each select="ex:node-set($all)//*[local-name() = 'trk' and starts-with(*[local-name() = 'trkseg']/*[local-name() = 'trkpt']/*[local-name() = 'time'][1],$date)]">
        <!-- xsl:for-each select="ex:node-set($all)//*[local-name() = 'trk']" -->
            <xsl:sort select="*[local-name() = 'trkseg']/*[local-name() = 'trkpt']/*[local-name() = 'time'][1]"/>
            <xsl:copy-of select="."/>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:variable name="allsort" select="ex:node-set($allsort0)"/>

    <xsl:template match="/">
        <xsl:element name="gpx" namespace="http://www.topografix.com/GPX/1/0">
            <xsl:attribute name="version">1.0</xsl:attribute>
            <xsl:attribute name="creator">mergetracksbydate.xsl</xsl:attribute>
            <xsl:call-template name="copytrxnamed"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="copytrxnamed">
        <xsl:param name="index" select="1"/>
        <xsl:param name="set" select="$allsort"/>
        <xsl:for-each select="$set/*[$index]">
            <xsl:copy>
                <xsl:copy-of select="@*"/>
                <xsl:element name="name" namespace="{namespace-uri()}">
                    <xsl:number value="$index" format="01"/><xsl:value-of select="concat(' ',*[local-name() = 'name'])"/>
                </xsl:element>
                <xsl:copy-of select="*[local-name() = 'trkseg']"/>
            </xsl:copy>
            <xsl:if test="following-sibling::*">
                <xsl:call-template name="copytrxnamed">
                    <xsl:with-param name="index" select="$index + 1"/>
                    <xsl:with-param name="set" select="$set"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
</xsl:transform>

