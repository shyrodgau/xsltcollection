<?xml version="1.0" encoding="utf-8"?>

<!-- output single html file for all nodes -->

<xsl:transform version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
     xmlns:ddd="urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/" 
     xmlns:dc="http://purl.org/dc/elements/1.1/"
     xmlns:upnp="urn:schemas-upnp-org:metadata-1-0/upnp/" 
     xmlns:sec="http://www.sec.co.kr/"
     xmlns:fx="http://exslt.org/functions"
     xmlns:dlna="urn:schemas-dlna-org:metadata-1-0/"
     extension-element-prefixes="fx">
    

<xsl:output method="html"/>

<xsl:variable name="quot" select="'&quot;'"/>

<xsl:template name="machelinktext">
    <xsl:param name="target" select="''"/>
    <xsl:param name="text"/>
    <xsl:param name="onclick" select="''"/>
    <a>
        <xsl:attribute name="href">
            <xsl:value-of select="concat('#',$target)"/>
        </xsl:attribute>
        <xsl:if test="$onclick != ''">
            <xsl:attribute name="onclick">
                <xsl:value-of select="concat($onclick,'; return false;')"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="'' = $text">
                <xsl:text>e m p t y ?</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </a>
</xsl:template>

<xsl:template match="*" mode="printinfo">
    <xsl:param name="top" select="1"/>
    <xsl:param name="omitns" select="0"/>
    <xsl:if test="$top != 1 and (* or @*)">
        <b>&lt;</b><xsl:value-of select="concat(name(), ': ')"/><!-- br/ -->
    </xsl:if>
    <!-- xsl:for-each select="@*[(local-name() != 'parentID') and (local-name() != 'id')]" -->
    <!-- xsl:for-each select="@*" -->
    <xsl:for-each select="@*[(local-name() != 'parentID')]">
        <xsl:value-of select="concat('  @', name(), ': ', .)"/><br/>
    </xsl:for-each>
    <!-- xsl:for-each select="@*[(local-name() = 'parentID') or (local-name() = 'id')]" -->
    <!-- xsl:for-each select="@*[(local-name() = 'parentID')]">
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
            <xsl:if test="*[namespace-uri() = 'http://purl.org/dc/elements/1.1/' and name() != 'dc:title' and not(*) and not(@*)]">
                <b>dc: </b>
                <xsl:apply-templates select="*[namespace-uri() = 'http://purl.org/dc/elements/1.1/' and name() != 'dc:title' and not(*) and not(@*)]" mode="printinfo">
                    <xsl:with-param name="top" select="0"/>
                    <xsl:with-param name="omitns" select="1"/>
                </xsl:apply-templates><br/>
            </xsl:if>
            <xsl:if test="*[namespace-uri() = 'urn:schemas-upnp-org:metadata-1-0/upnp/' and not(*) and not(@*)]">
                <b>upnp: </b>
                <xsl:apply-templates select="*[namespace-uri() = 'urn:schemas-upnp-org:metadata-1-0/upnp/' and not(*) and not(@*)]" mode="printinfo">
                    <xsl:with-param name="top" select="0"/>
                    <xsl:with-param name="omitns" select="1"/>
                </xsl:apply-templates><br/>
            </xsl:if>
            <xsl:if test="*[(namespace-uri() != 'urn:schemas-upnp-org:metadata-1-0/upnp/' and namespace-uri() != 'http://purl.org/dc/elements/1.1/') or * or @*]">
                <xsl:apply-templates select="*[(namespace-uri() != 'urn:schemas-upnp-org:metadata-1-0/upnp/' and namespace-uri() != 'http://purl.org/dc/elements/1.1/') or * or @*]" mode="printinfo">
                    <xsl:with-param name="top" select="0"/>
                </xsl:apply-templates>
            </xsl:if>
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
        <xsl:when test="$omitns != 0">
            <xsl:value-of select="concat(local-name(), ': ', translate(.,' ','&#xa0;'),' ')"/><b><xsl:text>&#xb7; </xsl:text></b>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="concat(name(), ': ', .)"/><br/>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="$top != 1 and (* or @*)">
        <xsl:value-of select="name()"/><b>/&gt;</b><br/>
    </xsl:if>
</xsl:template>

<xsl:template name="makenode">
    <xsl:param name="id"/>
    <xsl:param name="prefix" select="''"/>
    <xsl:param name="isroot" select="0"/>
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
    <xsl:if test="$metadoc/ddd:DIDL-Lite/*">
        <div id="{concat('F_',$id)}">
        <xsl:if test="$isroot = 0">
            <xsl:attribute name="style">display:none;</xsl:attribute>
        </xsl:if>
        <h2><a>
            <xsl:attribute name="name">
                <xsl:value-of select="$id"/>
            </xsl:attribute>
            <xsl:if test="$prefix != ''">
                    <xsl:call-template name="machelinktext">
                        <xsl:with-param name="target" select="$metadoc/ddd:DIDL-Lite/*/@parentID"/>
                        <xsl:with-param name="text" select="$prefix"/>
                    </xsl:call-template>
                    <xsl:text> / </xsl:text>
            </xsl:if>
            <xsl:call-template name="machelinktext">
                <xsl:with-param name="onclick">
                    <xsl:text>document.getElementById("X_</xsl:text><xsl:value-of select="$id"/><xsl:text>").style["display"]="block"; document.getElementById("F_</xsl:text><xsl:value-of select="$id"/><xsl:text>").style["display"]="none"</xsl:text>
                </xsl:with-param>
                <xsl:with-param name="text" select="$myname"/>
            </xsl:call-template>
        </a></h2>
         <xsl:text>@parentID: </xsl:text><xsl:value-of select="@parentID"/><xsl:text> (</xsl:text>
         <xsl:call-template name="machelinktext">
            <xsl:with-param name="target" select="@parentID"/>
            <xsl:with-param name="text" select="concat($prefix,'/',$myname)"/>
         </xsl:call-template>
         <xsl:text>)</xsl:text><br/>
        <xsl:apply-templates mode="printinfo" select="$metadoc/ddd:DIDL-Lite/*"/>
        <xsl:if test="local-name($metadoc/ddd:DIDL-Lite/*[dc:title]) = 'container'">
            <a name="{concat('st_',$id)}" href="{concat('#nx_',$id)}" style="font-size:50%;">&gt;&gt;&gt;</a><br/>
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
                            <div id="{concat('X_',@id)}">
                            <xsl:choose>
                                <xsl:when test="0 != dlna:checkid(@id)">
                                    <b>
                                         <xsl:call-template name="machelinktext">
                                            <xsl:with-param name="onclick">
                                                <xsl:text>if (null != document.getElementById("F_</xsl:text><xsl:value-of select="@id"/><xsl:text>")) {document.getElementById("F_</xsl:text><xsl:value-of select="@id"/><xsl:text>").style["display"]="block"; document.getElementById("X_</xsl:text><xsl:value-of select="@id"/><xsl:text>").style["display"]="none";}</xsl:text>
                                            </xsl:with-param>
                                            <xsl:with-param name="text" select="dc:title/text()"/>
                                         </xsl:call-template>
                                    </b><br/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <b>
                                            <xsl:value-of select="dc:title/text()"/>
                                    </b><br/>
                                </xsl:otherwise>
                             </xsl:choose>
                             <xsl:text>@parentID: </xsl:text><xsl:value-of select="@parentID"/><xsl:text> (</xsl:text>
                             <xsl:call-template name="machelinktext">
                                <xsl:with-param name="target" select="@parentID"/>
                                <xsl:with-param name="text" select="concat($prefix,'/',$myname)"/>
                             </xsl:call-template>
                             <xsl:text>)</xsl:text>
                            <!-- xsl:apply-templates select="." mode="printinfo"/ -->
                            </div>
                            <!-- makenode creates the F_@id div, this must of course be outside the X_@id div to be clickable/visible at all -->
                            <xsl:call-template name="makenode">
                                <xsl:with-param name="id" select="@id"/>
                                <xsl:with-param name="prefix" select="concat($prefix,'/',$myname)"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                             <b><xsl:value-of select="dc:title"/></b><br/>
                             <xsl:text>@parentID: </xsl:text><xsl:value-of select="@parentID"/><xsl:text> (</xsl:text>
                             <xsl:call-template name="machelinktext">
                                <xsl:with-param name="target" select="@parentID"/>
                                <xsl:with-param name="text" select="concat($prefix,'/',$myname)"/>
                             </xsl:call-template><xsl:text>)</xsl:text><br/>
                            <xsl:apply-templates select="." mode="printinfo"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </li>
            </xsl:for-each>
            </ul>
            <a name="{concat('nx_',$id)}" href="{concat('#st_',$id)}" style="font-size:50%;">&lt;&lt;&lt;</a><br/>
        </xsl:if>
        </div>
    </xsl:if>
</xsl:template>

<xsl:template match="/">
    <html><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <style class="text/css">
    .x {display:none;}
    .f {display:block;}
    </style>
    </head>
    <body>
    <xsl:call-template name="makenode">
        <xsl:with-param name="id" select="ddd:DIDL-Lite/*[1]/@id"/>
        <xsl:with-param name="isroot" select="1"/>
    </xsl:call-template>
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

</xsl:transform>

