<?xml version="1.0" encoding="utf-8" standalone="yes"?>

<!--
NOTE
This will force gpx 1.0 
-->

<xsl:transform version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template match="*[local-name() = 'trkpt']">
        <xsl:element name="{local-name()}" namespace="http://www.topografix.com/GPX/1/0">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="*[local-name() = 'ele']"/>
            <xsl:apply-templates select="*[local-name() = 'time']"/>
            <xsl:if test="*[local-name() = 'extensions']/*[local-name() = 'compass'] and not(*[local-name() = 'course'])">
                <xsl:element name="course" namespace="http://www.topografix.com/GPX/1/0"><xsl:value-of select="*[local-name() = 'extensions']/*[local-name() = 'compass']"/></xsl:element>
            </xsl:if>
            <xsl:if test="not(*[local-name() = 'speed'])">
                <xsl:apply-templates select="*[local-name() = 'extensions']/*[local-name() = 'speed']"/>
            </xsl:if>
            <xsl:apply-templates select="*[local-name() = 'magvar']"/>
            <xsl:apply-templates select="*[local-name() = 'geoidheight']"/>
            <xsl:apply-templates select="*[local-name() = 'name']"/>
            <xsl:apply-templates select="*[local-name() = 'cmt']"/>
            <xsl:if test="not(*[local-name() = 'cmt']) and *[local-name() = 'extensions']/*[local-name() = 'compass_accuracy']">
                <xsl:element name="cmt" namespace="http://www.topografix.com/GPX/1/0"><xsl:value-of select="concat('Compass accuracy: ',*[local-name() = 'extensions']/*[local-name() = 'compass_accuracy'])"/></xsl:element>
            </xsl:if>
            <xsl:apply-templates select="*[local-name() = 'desc']"/>
            <xsl:apply-templates select="*[local-name() = 'src']"/>
            <xsl:apply-templates select="*[local-name() = 'url']"/>
            <xsl:apply-templates select="*[local-name() = 'urlname']"/>
            <xsl:apply-templates select="*[local-name() = 'sym']"/>
            <xsl:apply-templates select="*[local-name() = 'type']"/>
            <xsl:apply-templates select="*[local-name() = 'fix']"/>
            <xsl:apply-templates select="*[local-name() = 'sat']"/>
            <xsl:apply-templates select="*[local-name() = 'hdop']"/>
            <xsl:apply-templates select="*[local-name() = 'vdop']"/>
            <xsl:apply-templates select="*[local-name() = 'pdop']"/>
            <!-- xsl:apply-templates select="*[local-name() = 'extensions']" mode="nons"/ -->
        </xsl:element>
    </xsl:template>
    <xsl:template match="*">
        <xsl:element name="{local-name()}" namespace="http://www.topografix.com/GPX/1/0">
            <xsl:copy-of select="@*[local-name() != 'version']"/>
            <xsl:if test="@*[local-name() = 'version'] = '1.1'">
                <xsl:attribute name="version">1.0</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <!--xsl:template match="*" mode="nons">
        <xsl:element name="{local-name()}" namespace="urn:mal.from.logger">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template -->
    <xsl:template match="comment()">
        <xsl:copy/>
    </xsl:template>
</xsl:transform>

