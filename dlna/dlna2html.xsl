<?xml version="1.0" encoding="utf-8"?>

<!-- output html files for all nodes -->
<!-- start node is 0.html if 0_meta.xml is passed as input -->
<xsl:transform version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
     xmlns:xr="http://xml.apache.org/xalan/redirect"
     xmlns:ddd="urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/" 
     xmlns:dc="http://purl.org/dc/elements/1.1/"
     xmlns:upnp="urn:schemas-upnp-org:metadata-1-0/upnp/" 
     xmlns:sec="http://www.sec.co.kr/"
     xmlns:dlna="urn:schemas-dlna-org:metadata-1-0/"
     xmlns:ex="http://exslt.org/common"
     xmlns:fx="http://exslt.org/functions"
     extension-element-prefixes="xr ex fx">
    

<xsl:output method="html"/>

<xsl:template name="machelinktext">
    <xsl:param name="target"/>
    <xsl:param name="text"/>
    <a>
        <xsl:attribute name="href">
            <xsl:value-of select="concat($target,'.html')"/>
        </xsl:attribute>
        <xsl:choose>
            <xsl:when test="'' = normalize-space($text)">
                <xsl:text>e m p t y ?</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </a>
</xsl:template>

<xsl:template match="*" mode="printinfo">
    <xsl:param name="top" select="1"/>
    <xsl:if test="$top != 1 and (* or @*)">
        <xsl:value-of select="concat('&lt;', name(), ': ')"/><br/>
    </xsl:if>
    <!-- xsl:for-each select="@*[(local-name() != 'parentID') and (local-name() != 'id')]" -->
    <xsl:for-each select="@*">
        <xsl:value-of select="concat('  @', name(), ': ', .)"/><br/>
    </xsl:for-each>
    <!-- xsl:for-each select="@*[(local-name() = 'parentID') or (local-name() = 'id')]">
        <a>
        <xsl:attribute name="href">
            <xsl:value-of select="concat('#',.)"/>
        </xsl:attribute>
        <xsl:value-of select="concat('  @', name(), ': ', .)"/>
        </a><br/>
    </xsl:for-each -->
    <xsl:variable name="urlsuff" select="translate(substring(local-name(),string-length(local-name())-2),'URLI','urli')"/>
    <xsl:choose>
        <xsl:when test="*">
            <xsl:apply-templates select="*" mode="printinfo">
                <xsl:with-param name="top" select="0"/>
            </xsl:apply-templates>
        </xsl:when>
        <xsl:when test="$urlsuff = 'url' or $urlsuff = 'uri' or starts-with(.,'http://') or starts-with(.,'https://')">
            <xsl:value-of select="concat(name(), ': ')"/>
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="."/>
                </xsl:attribute>
                <xsl:value-of select="."/>
            </a><br/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="concat(name(), ': ', .)"/><br/>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="$top != 1 and (* or @*)">
        <xsl:value-of select="concat(name(), '&gt; ')"/><br/>
    </xsl:if>
</xsl:template>

<fx:function name="dc:makeprefix">
    <xsl:param name="parentid"/>
    <xsl:param name="prefixes" select="''"/>
    <xsl:variable name="metadoc" select="document(concat($parentid,'_meta.xml'))"/>
    <fx:result>
        <xsl:choose>
            <xsl:when test="($parentid != '0') and ($parentid != '-1')  and '' = $prefixes">
                <!--xsl:message>A <xsl:value-of select="$parentid"/> &#xa;</xsl:message -->
                <xsl:choose>
                    <xsl:when test="$metadoc/ddd:DIDL-Lite/*/@parentID and $metadoc/ddd:DIDL-Lite/*/dc:title">
                        <xsl:value-of select="dc:makeprefix($metadoc/ddd:DIDL-Lite/*/@parentID,$metadoc/ddd:DIDL-Lite/*/dc:title)"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:text></xsl:text>
                     </xsl:otherwise>
                 </xsl:choose>
            </xsl:when>
            <xsl:when test="($parentid != '-1')  and $parentid != '0'">
                <!--xsl:message>2 <xsl:value-of select="$parentid"/> &#xa;</xsl:message-->
                <xsl:choose>
                    <xsl:when test="$metadoc/ddd:DIDL-Lite/*/@parentID and $metadoc/ddd:DIDL-Lite/*/dc:title">
                        <xsl:value-of select="dc:makeprefix($metadoc/ddd:DIDL-Lite/*/@parentID,concat($metadoc/ddd:DIDL-Lite/*/dc:title,'/',$prefixes))"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:text></xsl:text>
                     </xsl:otherwise>
                 </xsl:choose>
            </xsl:when>
            <xsl:when test="$parentid = '-1'">
                <!--xsl:message>0 <xsl:value-of select="$parentid"/> &#xa;</xsl:message-->
            </xsl:when>
            <xsl:otherwise>
                <!--xsl:message>c <xsl:value-of select="$parentid"/> &#xa;</xsl:message-->
                <xsl:value-of select="concat('/Root/',$prefixes)"/>
            </xsl:otherwise>
        </xsl:choose>
    </fx:result>
</fx:function>

<xsl:template name="makehtml">
    <xsl:param name="id"/>
    <xsl:param name="prefix" select="''"/>
    <xsl:param name="metadoc" select="document(concat($id,'_meta.xml'))"/>
    <xsl:param name="childoc" select="document(concat($id,'_chil.xml'))"/>
    <xsl:param name="myname" select="$metadoc//dc:title"/>
    <xsl:variable name="prefixx">
        <xsl:choose>
            <xsl:when test="'' != $prefix">
                <xsl:value-of select="$prefix"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="dc:makeprefix($metadoc/ddd:DIDL-Lite/*/@parentID)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
            <html><head><title>
            <xsl:value-of select="concat($id,' - (',$prefixx,'/) ',$myname)"/>
            </title><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /></head><body>
            <h1>
            <xsl:choose>
                <xsl:when test="$prefixx = ''">
                    <xsl:value-of select="$myname"/>
                </xsl:when>
                <xsl:when test="starts-with($prefixx,'/Root/')">
                    <xsl:call-template name="machelinktext">
                        <xsl:with-param name="target" select="0"/>
                        <xsl:with-param name="text" select="'/Root'"/>
                    </xsl:call-template>
                    <xsl:if test="'' != substring-after($prefixx,'/Root/')">
                        <xsl:text>/</xsl:text>
                        <xsl:call-template name="machelinktext">
                            <xsl:with-param name="target" select="$metadoc/ddd:DIDL-Lite/*/@parentID"/>
                            <xsl:with-param name="text" select="substring-after($prefixx,'/Root/')"/>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:value-of select="concat('/ ',$myname)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="machelinktext">
                        <xsl:with-param name="target" select="$metadoc/ddd:DIDL-Lite/*/@parentID"/>
                        <xsl:with-param name="text" select="$prefixx"/>
                    </xsl:call-template>
                    <xsl:value-of select="concat('/ ',$myname)"/>
                </xsl:otherwise>
            </xsl:choose>
            </h1>
            <xsl:apply-templates mode="printinfo" select="$metadoc/ddd:DIDL-Lite/*"/>
            <xsl:if test="local-name($metadoc/ddd:DIDL-Lite/*[dc:title]) = 'container'">
                <ul>
                <xsl:for-each select="$childoc/ddd:DIDL-Lite/*">
                    <li>
                        <xsl:choose>
                            <xsl:when test="upnp:albumArtURI != ''">
                                <img style="float: left; position: relative;  right: 0.5em; align: left;">
                                <!--img style="float: left; position: absolute;  left: 1em; align: right;"-->
                                    <xsl:attribute name="src">
                                        <xsl:value-of select="upnp:albumArtURI"/>
                                    </xsl:attribute>
                                </img>
                            </xsl:when>
                            <xsl:when test="ddd:res[starts-with(@protocolInfo,'http-get:') and contains(@protocolInfo,'_TN;DLNA.O')]">
                                <img style="float: left; position: relative;  right: 0.5em; align: left;">
                                <!--img style="float: left; position: absolute;  left: 1em; align: right;"-->
                                    <xsl:attribute name="src">
                                        <xsl:value-of select="ddd:res[starts-with(@protocolInfo,'http-get:') and contains(@protocolInfo,'_TN;DLNA.O')][1]"/>
                                    </xsl:attribute>
                                </img>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:choose>
                            <xsl:when test="local-name() = 'container'">
                                <b>
                                     <xsl:call-template name="machelinktext">
                                        <xsl:with-param name="target" select="@id"/>
                                        <xsl:with-param name="text" select="dc:title"/>
                                     </xsl:call-template>
                                </b><br/>
                                <xsl:apply-templates select="." mode="printinfo"/>
                                <xsl:if test="element-available('xr:write')">
                                    <xsl:call-template name="makenode">
                                        <xsl:with-param name="id" select="@id"/>
                                        <xsl:with-param name="prefix" select="concat($prefix,'/',$myname)"/>
                                    </xsl:call-template>
                                 </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                 <b><xsl:value-of select="dc:title"/></b><br/>
                                 <xsl:text>Parent: </xsl:text>
                                 <xsl:choose>
                                 <xsl:when test="@parentID != $id">
                                     <xsl:call-template name="machelinktext">
                                        <xsl:with-param name="target" select="@parentID"/>
                                        <xsl:with-param name="text" select="concat($prefixx,'/',$myname)"/>
                                     </xsl:call-template>
                                  </xsl:when>
                                  <xsl:otherwise>
                                    <xsl:value-of select="concat($prefixx,'/',$myname)"/>
                                  </xsl:otherwise>
                                  </xsl:choose>
                                 <br/>
                                <xsl:apply-templates select="." mode="printinfo"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </li>
                </xsl:for-each>
                </ul>
            </xsl:if>
            </body></html>
</xsl:template>

<xsl:template name="makenode">
    <xsl:param name="id"/>
    <xsl:param name="prefix" select="''"/>
    <xsl:variable name="metadoc" select="document(concat($id,'_meta.xml'))"/>
    <xsl:variable name="childoc" select="document(concat($id,'_chil.xml'))"/>
    <xsl:variable name="myname2" select="$metadoc//dc:title"/>
    <xsl:variable name="myname">
        <xsl:choose>
            <xsl:when test="'' = normalize-space($myname2)">
                <xsl:text>e m p t y ?</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$myname2"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:if test="$metadoc/ddd:DIDL-Lite/* and $childoc/ddd:DIDL-Lite/*">
        <xsl:choose>
            <xsl:when test="element-available('xr:write')">
                <xr:write select="concat($id,'.html')">
                    <xsl:call-template name="makehtml">
                        <xsl:with-param name="id" select="$id"/>
                        <xsl:with-param name="prefix" select="$prefix"/>
                        <xsl:with-param name="metadoc" select="$metadoc"/>
                        <xsl:with-param name="childoc" select="$childoc"/>
                        <xsl:with-param name="myname" select="$myname"/>
                    </xsl:call-template>
                </xr:write>
            </xsl:when>
            <xsl:otherwise>
                    <xsl:call-template name="makehtml">
                        <xsl:with-param name="id" select="$id"/>
                        <xsl:with-param name="prefix" select="$prefix"/>
                        <xsl:with-param name="metadoc" select="$metadoc"/>
                        <xsl:with-param name="childoc" select="$childoc"/>
                        <xsl:with-param name="myname" select="$myname"/>
                    </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:if>
</xsl:template>

<xsl:template match="/">
  <xsl:if test="ddd:DIDL-Lite/*">
    <xsl:call-template name="makenode">
        <xsl:with-param name="id" select="ddd:DIDL-Lite/*[1]/@id"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

</xsl:transform>

