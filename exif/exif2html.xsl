<?xml version="1.0" encoding="utf-8"?>

<!-- this is for formatting exiftool -X -b ... output -->

<xsl:transform version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
     xmlns:ddd="urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/" 
     xmlns:dc="http://purl.org/dc/elements/1.1/"
     xmlns:upnp="urn:schemas-upnp-org:metadata-1-0/upnp/" 
     xmlns:sec="http://www.sec.co.kr/"
     xmlns:fx="http://exslt.org/functions"
     xmlns:ex="http://exslt.org/common"
     xmlns:dlna="urn:schemas-dlna-org:metadata-1-0/"
     extension-element-prefixes="fx">
    

<xsl:output method="html"/>

<xsl:param name="exifverssuff" select="'/1.0/'"/>
<xsl:param name="exifverspref" select="'http://ns.exiftool.ca/'"/>

<xsl:variable name="quot" select="'&quot;'"/>

<xsl:variable name="origdoc" select="/"/>
<xsl:variable name="allns0">
    <xsl:for-each select="//*">
        <xsl:variable name="nsu" select="namespace-uri()"/>
        <xsl:if test="not(preceding::*[namespace-uri() = $nsu]) and not(ancestor::*[namespace-uri() = $nsu])">
            <xsl:if test="starts-with($nsu,$exifverspref) and dlna:ends-with($nsu,$exifverssuff)">
                <ns><xsl:value-of select="substring-before($nsu,$exifverssuff)"/></ns>
                <ns><xsl:value-of select="dlna:striplastdir(substring-before($nsu,$exifverssuff))"/></ns>
            </xsl:if>
        </xsl:if>
    </xsl:for-each>
</xsl:variable>
<xsl:variable name="allns1" select="ex:node-set($allns0)"/>
<xsl:variable name="allns2">
    <xsl:for-each select="$allns1//ns">
        <xsl:variable name="c" select="."/>
        <xsl:if test="not($allns1//ns[starts-with($c,concat(.,'/'))]) and not(following::ns[$c = .])">
            <xsl:copy><xsl:copy-of select="text()"/>
                <xsl:copy-of select="$allns1//ns[starts-with(.,concat($c,'/'))]"/>
            </xsl:copy>
        </xsl:if>
    </xsl:for-each>
</xsl:variable>
<xsl:variable name="allns3" select="ex:node-set($allns2)"/>

<xsl:template match="ns">
    <xsl:variable name="c" select="text()"/>
    <xsl:variable name="cc" select="translate(substring-after($c,$exifverspref),'/','_')"/>
    <div id="{concat('V_',$cc)}"  style='display:none;'>
    <h2><a href="#">
        <xsl:attribute name="onclick">
            <xsl:text>document.getElementById('V_</xsl:text><xsl:value-of select="$cc"/><xsl:text>').style['display']='none'; document.getElementById('H_</xsl:text><xsl:value-of select="$cc"/><xsl:text>').style['display']='block'; return false;</xsl:text>
        </xsl:attribute>
        <xsl:value-of select="substring-after($c,$exifverspref)"/>
    </a></h2><ul>
        <xsl:for-each select="$origdoc//*[namespace-uri() = concat($c,$exifverssuff)]">
            <li><b><xsl:value-of select="local-name()"/></b>
                <xsl:for-each select="@*">
                    <xsl:value-of select="concat(' (',local-name(),'=',.,') ')"/>
                </xsl:for-each>
                <xsl:text>: </xsl:text>
            <xsl:choose>
                <xsl:when test="(contains(translate(local-name(),'IMAGEPCTUR','imagepctur'),'image') or contains(translate(local-name(),'IMAGEPCTUR','imagepctur'),'picture')) and @*[local-name() = 'datatype'] = 'http://www.w3.org/2001/XMLSchema#base64Binary'">
                    <!--img src="{concat('data:image/jpeg;base64,',normalize-space(text()))}" style="float: right; position: relative;  right: 0.5em; align: left;"/ -->
                    <img src="{concat('data:application/binary;base64,',normalize-space(text()))}" style="float: right; position: relative;  right: 0.5em; align: left;"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="text()"/>
                </xsl:otherwise>
            </xsl:choose>
            </li>
        </xsl:for-each>
        <xsl:apply-templates select="ns"/>
        </ul>
    </div>
    <div id="{concat('H_',$cc)}">
    <h2><a href="#">
        <xsl:attribute name="onclick">
            <xsl:text>document.getElementById('H_</xsl:text><xsl:value-of select="$cc"/><xsl:text>').style['display']='none'; document.getElementById('V_</xsl:text><xsl:value-of select="$cc"/><xsl:text>').style['display']='block'; return false;</xsl:text>
        </xsl:attribute>
        <xsl:value-of select="substring-after($c,$exifverspref)"/>
    </a></h2>
    </div>
</xsl:template>

<xsl:template match="/">
    <html><body>
    <!--xsl:copy-of select="$allns3"/ -->
        <xsl:apply-templates select="$allns3/ns"/>
    </body></html>
</xsl:template>

<fx:function name="dlna:checkid">
    <xsl:param name="id"/>
    <xsl:variable name="metadoc" select="document(concat($id,'_meta.xml'))"/>
    <xsl:variable name="childoc" select="document(concat($id,'_chil.xml'))"/>
    <fx:result>
        <xsl:choose>
            <xsl:when test="$metadoc//dc:title and $childoc/ddd:DIDL-Lite">
                <xsl:text>1</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>0</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </fx:result>
</fx:function>

<fx:function name="dlna:ends-with">
    <xsl:param name="s"/>
    <xsl:param name="end"/>
    <fx:result select="substring($s,string-length($s) - (string-length($end)-1)) = $end"/>
</fx:function>

<fx:function name="dlna:striplastdir">
    <xsl:param name="uri"/>
    <fx:result>
        <xsl:choose>
            <xsl:when test="not(contains(substring-after($uri,$exifverspref),'/'))">
                <xsl:value-of select="$uri"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="dlna:striplastdir(substring($uri,1,string-length($uri) - 1))"/>
            </xsl:otherwise>
        </xsl:choose>
    </fx:result>
</fx:function>

</xsl:transform>

