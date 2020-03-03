<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:str="http://exslt.org/strings"
                extension-element-prefixes="str">

    <!-- self citation -->
    <xsl:template name="self-citation">
        <xsl:param name="meta"/>

        <dl class="self-citation">
            <dd>
                <xsl:call-template name="self-citation-authors"/>
                <xsl:text>&#32;(</xsl:text>
                <span class="self-citation-year">
                    <xsl:value-of select="$pub-date/year"/>
                </span>
                <xsl:text>). </xsl:text>
                <xsl:apply-templates select="$title" mode="self-citation"/>
                <xsl:call-template name="title-punctuation">
                    <xsl:with-param name="title" select="$title"/>
                </xsl:call-template>
                <xsl:text>&#32;</xsl:text>
	            <span itemprop="isPartOf" itemscope="itemscope">
		            <span class="self-citation-journal"
		                  itemprop="isPartOf" itemscope="itemscope">
			          <span itemprop="name">
			          <xsl:text>QfI - Qualifizierung für Inklusion</xsl:text>
				  </span>
		            </span>
		            <xsl:text>, </xsl:text>
		            <span class="self-citation-volume">
			            <xsl:value-of select="$volume"/>
		            </span>
								<xsl:text>(</xsl:text>
		            <span class="self-citation-issue" itemprop="issueNumber">
			            <xsl:value-of select="$issue"/>
		            </span>
			    <xsl:text>), doi: </xsl:text>
	            </span>
                <!--span class="self-citation-elocation" itemprop="pageStart">
                    <xsl:value-of select="$meta/elocation-id"/>
                </span-->
								<xsl:variable name="doi-address">
									<xsl:choose>
									<xsl:when test="contains($doi, 'https://')">
										<xsl:value-of select="$doi"/>
									</xsl:when>
									<xsl:otherwise>
                    <xsl:value-of select="concat('https://doi.org/', $doi)"/>
									</xsl:otherwise>
								</xsl:choose>
								</xsl:variable>
                <a href="https://doi.org/{$doi}" itemprop="url">
                    <xsl:value-of select="$doi"/>
                </a>
            </dd>
        </dl>
    </xsl:template>

    <!-- self citation author names -->
    <xsl:template name="self-citation-authors">
    	<span class="self-citation-authors">
	    	<xsl:for-each select="$authors/contrib/name">
					<xsl:call-template name="ampersand-separator"/>
					<xsl:value-of select="surname"/>
					<xsl:text>, </xsl:text>
					<xsl:value-of select="substring(given-names, 1, 1)"/>
					<xsl:text>.</xsl:text>
					<xsl:call-template name="comma-separator"/>
	    	</xsl:for-each>
      </span>
    </xsl:template>

    <xsl:template match="article-title" mode="self-citation">
        <span class="self-citation-title">
            <xsl:apply-templates select="node()|@*"/>
        </span>
    </xsl:template>

       <xsl:template match="name" mode="self-citation">
        <xsl:apply-templates select="surname" mode="self-citation"/>
	<xsl:if test="given-names">
            <xsl:text>&#32;</xsl:text>
            <xsl:apply-templates select="given-names" mode="self-citation"/>
        </xsl:if>
        <xsl:if test="suffix">
            <xsl:text>&#32;</xsl:text>
            <xsl:apply-templates select="suffix" mode="self-citation"/>
        </xsl:if>
        <xsl:call-template name="comma-separator"/>
    </xsl:template>

    <xsl:template match="surname" mode="self-citation">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="suffix" mode="self-citation">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="given-names" mode="self-citation">
        <xsl:choose>
            <xsl:when test="@initials">
                <xsl:value-of select="@initials"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="str:tokenize(., ' .')">
                    <xsl:value-of select="substring(., 1, 1)"/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="collab" mode="self-citation">
        <xsl:apply-templates/>
        <xsl:call-template name="comma-separator"/>
    </xsl:template>
</xsl:stylesheet>
