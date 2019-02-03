<?xml version="1.0" encoding="utf-8" standalone="yes"?>

<!--
NOTE
The output will most likely not conform to neither
http://www.topografix.com/GPX/1/1/gpx.xsd
nor
http://www.topografix.com/GPX/1/0/gpx.xsd
BUT likely the input did not either 
-->

<xsl:transform version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template match="*[local-name() = 'trkpt']">
        <xsl:element name="local-name()" namespace="http://www.topografix.com/GPX/1/0">
            <xsl:copy-of select="@*|*[local-name() != 'ele']"/>
            <xsl:copy-of select="@*|*[local-name() != 'time']"/>
            <xsl:if test="*[local-name() = 'extensions']/*[local-name() = 'compass'] and not(*[local-name() = 'course'])">
                <xsl:element name="course" namespace="{namespace-uri()}"><xsl:value-of select="*[local-name() = 'extensions']/*[local-name() = 'compass']"/></xsl:element>
            </xsl:if>
            <xsl:if test="not(*[local-name() = 'speed'])">
                <xsl:copy-of select="*[local-name() = 'extensions']/*[local-name() = 'speed']"/>
            </xsl:if>
            <xsl:copy-of select="@*|*[local-name() != 'hdop']"/>
            <!-- xsl:copy-of select="*[local-name() = 'extensions']"/ -->
        </xsl:copy>
    </xsl:template>
    <xsl:template match="*">
        <xsl:element name="local-name()" namespace="http://www.topografix.com/GPX/1/0">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="comment()">
        <xsl:copy/>
    </xsl:template>
</xsl:transform>

