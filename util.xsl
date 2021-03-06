<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:php="http://php.net/xsl"
                exclude-result-prefixes="php">

    <!-- url-encode a string, if PHP functions are registered -->
    <xsl:template name="urlencode">
        <xsl:param name="value"/>

        <xsl:choose>
            <xsl:when test="function-available('php:function')">
                <xsl:value-of select="php:function('rawurlencode', string($value))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$value"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- convert a date string to a different format -->
    <xsl:template name="format-date">
        <xsl:param name="value"/>
        <xsl:param name="format"/>

        <xsl:value-of select="php:function('EmbedGalleyPlugin::formatDate', string($value), $format)"/>
    </xsl:template>

    <!-- add full stop to a title if not already there -->
    <xsl:template name="title-punctuation">
        <xsl:param name="title" select="."/>
        <xsl:variable name="last-character" select="substring($title, string-length($title))"/>
        <xsl:if test="not(contains($end-punctuation, $last-character))">
            <xsl:text>.</xsl:text>
        </xsl:if>
    </xsl:template>
	
    <!-- convert the first letter of a string to uppercase -->
    <xsl:template name="ucfirst">
        <xsl:param name="text"/>
        <xsl:value-of select="translate(substring($text, 1, 1) , 'abcdefghijklmnopqrstuvwxyzåöä', 'ABCDEFGHIJKLMNOPQRSTUVWXYZÅÖÄ')"/>
        <xsl:value-of select="substring($text, 2, string-length($text) - 1)"/>
    </xsl:template>	

    <xsl:template name="ampersand-separator">
        <xsl:variable name="seperator" select="' &amp; '"/>
        <xsl:if test="position() = last() and position() != 1">
            <xsl:value-of select="$seperator"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="comma-separator">
        <xsl:param name="separator" select="', '"/>
        <xsl:if test="position() != last()">
            <xsl:value-of select="$separator"/>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
