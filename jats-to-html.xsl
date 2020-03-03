<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" exclude-result-prefixes="xlink mml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mml="http://www.w3.org/1998/Math/MathML"
                xmlns:xlink="http://www.w3.org/1999/xlink">

    <xsl:strip-space elements="*"/>

    <xsl:output method="xml" encoding="utf-8" omit-xml-declaration="yes" indent="yes"/>

    <xsl:strip-space elements="contrib collab"/>

    <xsl:param name="public-reviews" select="false()"/>
    <xsl:param name="static-root" select="''"/>
	
	<xsl:param name="citation-style" select="ABNT"/>
	
    <xsl:param name="search-root" select="''"/>
    <xsl:param name="download-prefix" select="'file'"/>
    <xsl:param name="publication-type" select="'publication'"/>
    <xsl:param name="self-uri" select="/article/front/article-meta/self-uri/@xlink:href"/>

    <xsl:variable name="meta" select="/article/front/article-meta"/>
    <xsl:variable name="id" select="$meta/article-id[@pub-id-type='publisher-id']"/>
    <xsl:variable name="doi" select="$meta/article-id[@pub-id-type='doi']|$meta/elocation-id"/>
    <xsl:variable name="title" select="$meta/title-group/article-title"/>
    <xsl:variable name="pub-date" select="$meta/pub-date[@date-type='pub']|$meta/pub-date[@date-type='preprint']"/>
    <xsl:variable name="received-date" select="$meta/history/date[@date-type='received']"/>
    <xsl:variable name="published-date" select="$meta/history/date[@date-type='published']"/>
    <xsl:variable name="issue" select="$meta/issue"/>
    <xsl:variable name="volume" select="$meta/volume"/>
    <xsl:variable name="authors" select="$meta/contrib-group[@content-type='author']"/>
    <xsl:variable name="editors" select="$meta/contrib-group[@content-type='editor']"/>
		<xsl:variable name="license" select="$meta/permissions/license"/>
		<xsl:variable name="itemVersion" select="$meta/custom-meta-group/custom-meta[meta-name='version']/meta-value"/>

    <xsl:variable name="journal-meta" select="/article/front/journal-meta"/>
    <xsl:variable name="journal-title" select="$journal-meta/journal-title-group/journal-title"/>

    <xsl:variable name="abbrev-journal-title">
        <xsl:choose>
            <xsl:when test="$journal-meta/journal-title-group/abbrev-journal-title">
                <xsl:value-of select="$journal-meta/journal-title-group/abbrev-journal-title"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$journal-meta/journal-title-group/journal-title"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="end-punctuation">
        <xsl:text>.?!"')]}</xsl:text>
    </xsl:variable>

    <xsl:key name="ref" match="ref" use="@id"/>
	<xsl:key name="footn" match="fn" use="@id"/>
    <xsl:key name="aff" match="aff" use="@id"/>
    <xsl:key name="corresp" match="corresp" use="@id"/> <!-- remove when converted -->
    <xsl:key name="xrefs" match="xref[@ref-type='fn']" use="@rid"/>
		<xsl:key name="bibrefs" match="xref[@ref-type='bibr']" use="@rid"/>

    <xsl:include href="util.xsl"/>
    <xsl:include href="meta.xsl"/>
    <xsl:include href="front.xsl"/>
    <xsl:include href="self-citation.xsl"/>

    <!-- article -->
    <xsl:template match="/article">
		<article itemscope="itemscope" itemtype="http://schema.org/ScholarlyArticle">
			<xsl:apply-templates select="body"/>
			<xsl:apply-templates select="back"/>
			<xsl:apply-templates select="floats-group"/>
		</article>
    </xsl:template>

    <!-- table of content -->
    <xsl:template match="sec" mode="toc">
      <xsl:variable name="sec-id" select="@id"/>
      <li><a href="#{$sec-id}"><xsl:value-of select="title"/></a>
        <xsl:if test="sec">
  	  <ol><xsl:apply-templates select="sec" mode="toc"/></ol>
        </xsl:if>
      </li>	
    </xsl:template>

    <!-- footnote and affiliation labels -->
    <xsl:template match="fn/label | aff/label">
        <a class="article-label">
            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <!-- funding-statement -->
    <xsl:template match="funding-statement" mode="back">
        <h3 class="heading">Funding</h3>
        <p>
            <xsl:apply-templates select="node()"/>
        </p>
    </xsl:template>

    <xsl:template match="body">
	<div id="table-of-contents">
	  <h2>Inhaltsverzeichnis</h2>
	  <ol>
	    <xsl:apply-templates select="sec" mode="toc"/>
	    <li class="no-list-style"><a href="#literatur-liste">Literatur</a></li>
	    <li class="no-list-style"><a href="#contact">Kontakt</a></li>
	    <li class="no-list-style"><a href="#how-to-cite">Zitation</a></li>
 	  </ol>
	</div>
        <main>
            <div class="{local-name()}" lang="en">
                <xsl:apply-templates select="node()|@*"/>
            </div>

            <!--xsl:call-template name="footnotes">
                <xsl:with-param name="footnotes" select="descendant::fn[preceding-sibling::xref[@ref-type='fn']]"/>
            </xsl:call-template-->
        </main>
    </xsl:template>

    <!-- don't display footnotes inline -->
    <xsl:template match="body//fn[preceding-sibling::xref[@ref-type='fn']]"/>

    <xsl:template name="footnotes">
        <xsl:param name="footnotes"/>
	
        <xsl:if test="$footnotes">
            <div id="article-footnotes" class="fn-group">
                <xsl:for-each select="$footnotes">
										<xsl:sort select="label"/>
		    						<xsl:variable name="xref" select="key('xrefs', @id)"/>
                    <div class="fn article-footnote">
                        <xsl:apply-templates select="node()|@*"/>
                    	<a href="#{$xref/@id}" class="fn-backreference">&#8617;</a>
		    </div>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="contact">
	<h3>Kontakt:</h3>
        <xsl:call-template name="correspondence"/>
    </xsl:template>

    <xsl:template name="how-to-cite">
	<h3>Zitation:</h3>
        <xsl:call-template name="self-citation"/>
    </xsl:template>

    <xsl:template name="received">
	<h3>Eingereicht:</h3>
    	<div id="received-date-details">
	    <xsl:value-of select="$received-date/day"/>.<xsl:value-of select="$received-date/month"/>.<xsl:value-of select="$received-date/year"/>
	</div>
    </xsl:template>

    <xsl:template name="published">
	<h3>Veröffentlicht:</h3>
    	<div id="published-date-details">
	    <xsl:value-of select="$published-date/day"/>.<xsl:value-of select="$published-date/month"/>.<xsl:value-of select="$published-date/year"/>
	</div>
    </xsl:template>

    <xsl:template name="license-info">
				<xsl:choose>
					<xsl:when test="$license != '' and $license != 'Select license'">
						<xsl:variable name="licence-url-postfix" select="substring-after($licence, 'creativecommons.org/licenses/')"/>
						<img id="cc-licence-icon" src="https://licensebuttons.net/l/{$licence-url-postfix}88x15.png" alt="Creative-Commons"/>
						<p>Dieser Text ist lizenziert unter einer <a href="https://creativecommons.org/licenses/{$licence-url-postfix}deed.de" target="_blank">Creative Commons Lizenz.</a></p>
					</xsl:when>
					<xsl:otherwise>
						<img id="cc-licence-icon" src="https://licensebuttons.net/l/by-nd/4.0/80x15.png" alt="Creative-Commons-BY-ND-Icon"/>
						<p>Dieser Text ist lizenziert unter einer <a href="https://creativecommons.org/licenses/by-nd/4.0/deed.de" target="_blank">Creative Commons Namensnennung - Keine Bearbeitungen 4.0 International Lizenz.</a></p>
					</xsl:otherwise>
				</xsl:choose>
    </xsl:template>
   
    <xsl:template match="back">
        <footer class="{local-name()}">
	    <xsl:call-template name="footnotes">
                <xsl:with-param name="footnotes" select="fn-group/fn"/>
            </xsl:call-template>
            <xsl:apply-templates select="node()[not(local-name() = 'fn-group')]|@*"/>
	    <div id="contact"><xsl:call-template name="contact"/></div>
            <div id="how-to-cite"><xsl:call-template name="how-to-cite"/></div> 
            <div id="received-date"><xsl:call-template name="received"/></div>
	    <div id="licence"><xsl:call-template name="license-info"/></div> 
	</footer>
    </xsl:template>

    <xsl:template name="correspondence">
	<xsl:variable name="corr-author" select="$authors//contrib[@corresp='yes']"/>
	<xsl:variable name="corr-affiliation" select="key('aff', $corr-author/xref[@ref-type='aff']/@rid)"/>
	<xsl:variable name="corr-email" select="$corr-author/email"/>
	<xsl:variable name="organisation" select="$corr-affiliation/institution[@content-type='orgname']"/>
	<xsl:variable name="institut" select="$corr-affiliation/institution[@content-type='orgdiv1']"/>
	<div id="correspondence-details">
	    <xsl:value-of select="$corr-author/name/surname"/>
	    <xsl:text>, </xsl:text>
	    <xsl:value-of select="$corr-author/name/given-names"/>
	    <xsl:text>, </xsl:text>
			<xsl:if test="$organisation">
	    	<xsl:value-of select="$organisation"/>
	    	<xsl:text>, </xsl:text>
			</xsl:if>
	    <xsl:if test="$institut">
				<xsl:value-of select="$corr-affiliation/institution[@content-type='orgdiv1']"/>
	    	<xsl:text>, </xsl:text>
	    </xsl:if>
			<xsl:value-of select="$corr-affiliation/addr-line[@content-type='street-address']"/>
	    <xsl:text>, </xsl:text>
	    <xsl:value-of select="$corr-affiliation/postal-code"/>
	    <xsl:text> </xsl:text>
	    <xsl:value-of select="$corr-affiliation/city"/>
	    <br/><xsl:text>E-Mail: </xsl:text>
	    <a href="mailto:{$corr-email}"><xsl:value-of select="$corr-email"/></a>
	</div>
    </xsl:template>

    <xsl:template match="sec[@sec-type='additional-information']">
        <div class="{local-name()}">
            <xsl:apply-templates select="node()|@*"/>
            <xsl:apply-templates select="$meta/funding-group/funding-statement" mode="back"/>
        </div>
    </xsl:template>

    <!-- any label -->
    <xsl:template match="label">
        <span class="article-label">
            <xsl:apply-templates select="node()|@*"/>
        </span>
    </xsl:template>

    <xsl:template match="label" mode="caption">
        <span class="caption-label">
            <xsl:apply-templates select="node()|@*"/>
            <xsl:text>:&#32;</xsl:text>
        </span>
    </xsl:template>

    <!-- simple list, or list with labels -->
    <xsl:template match="list[@list-type='simple'] | list[@list-type='labelled']">
        <ul style="list-style-type:none;display:table">
            <xsl:attribute name="class">
                <xsl:choose>
                    <xsl:when test="list-item/label">
                        <xsl:text>list list-simple list-labelled</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>list list-simple</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>

            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()" mode="list-simple"/>
        </ul>
    </xsl:template>

    <!-- simple list item  -->
    <xsl:template match="list-item" mode="list-simple">
        <li class="{local-name()}" style="display:table-row">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="label" mode="list-simple"/>
            <div class="list-item-content" style="display:table-cell">
                <xsl:apply-templates select="*[not(self::label)]"/>
            </div>
        </li>
    </xsl:template>

    <!-- simple list item label -->
    <xsl:template match="label" mode="list-simple">
        <div class="list-item-label" style="display:table-cell;text-align:right">
            <xsl:apply-templates select="node()|@*"/>
        </div>
    </xsl:template>

    <!-- alpha list, uppercase -->
    <xsl:template match="list[@list-type='alpha-upper']">
        <ol class="{local-name()}" style="list-style-type:upper-alpha">
            <xsl:apply-templates select="node()|@*"/>
        </ol>
    </xsl:template>

    <!-- alpha list, lowercase -->
    <xsl:template match="list[@list-type='alpha-lower']">
        <ol class="{local-name()}" style="list-style-type:lower-alpha">
            <xsl:apply-templates select="node()|@*"/>
        </ol>
    </xsl:template>

    <!-- roman list, uppercase -->
    <xsl:template match="list[@list-type='roman-upper']">
        <ol class="{local-name()}" style="list-style-type:upper-roman">
            <xsl:apply-templates select="node()|@*"/>
        </ol>
    </xsl:template>

    <!-- roman list, lowercase -->
    <xsl:template match="list[@list-type='roman-lower']">
        <ol class="{local-name()}" style="list-style-type:lower-roman">
            <xsl:apply-templates select="node()|@*"/>
        </ol>
    </xsl:template>

    <!-- ordered list -->
    <xsl:template match="list[@list-type='order']">
        <ol class="{local-name()}">
            <xsl:apply-templates select="node()|@*"/>
        </ol>
    </xsl:template>

    <!-- unordered list (bullets)  -->
    <xsl:template match="list">
        <ul class="{local-name()}">
            <xsl:apply-templates select="node()|@*"/>
        </ul>
    </xsl:template>

    <!-- list item -->
    <xsl:template match="list-item">
        <li class="{local-name()}">
            <xsl:apply-templates select="node()|@*"/>
        </li>
    </xsl:template>

    <!-- paragraph -->
    <xsl:template match="p">
        <p>
            <xsl:apply-templates select="node()|@*"/>
        </p>
    </xsl:template>

    <!-- paragraph in the body -->
    <xsl:template match="body//p">
        <p>
            <!-- a sequential id for each paragraph -->
            <xsl:attribute name="id">
                <xsl:text>p-</xsl:text>
                <xsl:number count="body//p" level="any"/>
            </xsl:attribute>
            <xsl:apply-templates select="node()|@*"/>
	<!-- paragraph count -->
	<xsl:if test="(./text() or./*/text()) and (not(ancestor::list) or ancestor::list and not(ancestor::list-item/following-sibling::list-item)) and not(ancestor::disp-quote) or name(.)='disp-quote'">
	  <xsl:number format=" [1]" level="any" count="body//p[(./text() or./*/text()) and (not(ancestor::list) or ancestor::list and not(ancestor::list-item/following-sibling::list-item)) and not(ancestor::disp-quote)]|body//disp-quote" />
	</xsl:if>
        </p>
    </xsl:template>

    <!-- quotes -->
    <xsl:template match="disp-quote">
        <blockquote class="{local-name()}">
            <xsl:apply-templates select="node()|@*"/>
						<!-- paragraph count -->
	  				<span><xsl:number format=" [1]" level="any" count="body//p[(./text() or./*/text()) and (not(ancestor::list) or ancestor::list and not(ancestor::list-item/following-sibling::list-item)) and not(ancestor::disp-quote)]|body//disp-quote" /></span>
        </blockquote>
				
    </xsl:template>
    
		<!-- the article title -->
    <xsl:template match="article-title">
        <h1 class="{local-name()}" itemprop="name headline">
            <xsl:apply-templates select="node()|@*"/>
        </h1>
    </xsl:template>

    <!-- people -->
    <xsl:template match="person-group">
        <div class="{local-name()}">
            <xsl:apply-templates select="node()|@*"/>
        </div>
    </xsl:template>

    <!-- name -->
    <xsl:template name="name">
	<xsl:call-template name="ampersand-separator"/>
        <xsl:apply-templates select="given-names"/>
        <xsl:if test="surname">
            <xsl:text>&#32;</xsl:text>
            <xsl:apply-templates select="surname"/>
        </xsl:if>
        <xsl:if test="suffix">
            <xsl:text>&#32;</xsl:text>
            <xsl:apply-templates select="suffix"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="surname">
	<span class="{local-name()}" itemprop="familyName">
            <xsl:apply-templates select="node()|@*"/>
        </span>
    </xsl:template>

    <!-- name -->
    <xsl:template match="name">
        <span class="{local-name()}" itemprop="name">
            <xsl:call-template name="name"/>
        </span>
        <xsl:call-template name="comma-separator"/>
    </xsl:template>

    <xsl:template match="collab">
        <span class="{local-name()} name" itemprop="name">
            <xsl:apply-templates select="node()|@*"/>
        </span>
    </xsl:template>

    <!-- text formatting -->
    
    <xsl:template match="italic">
        <span class="{local-name()}">
            <xsl:call-template name="add-style">
                <xsl:with-param name="style">font-style:italic</xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates select="node()|@*"/>
        </span>
    </xsl:template>

    <xsl:template match="bold">
        <span class="{local-name()}">
            <xsl:call-template name="add-style">
                <xsl:with-param name="style">font-weight:bold</xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates select="node()|@*"/>
        </span>
    </xsl:template>
    

    <xsl:template match="italic">
        <i>
            <xsl:apply-templates select="node()|@*"/>
        </i>
    </xsl:template>

    <xsl:template match="bold">
        <b>
            <xsl:apply-templates select="node()|@*"/>
        </b>
    </xsl:template>

    <xsl:template match="sub">
        <sub>
            <xsl:apply-templates select="node()|@*"/>
        </sub>
    </xsl:template>

    <xsl:template match="sup">
        <sup>
            <xsl:apply-templates select="node()|@*"/>
        </sup>
    </xsl:template>

    <xsl:template match="underline">
        <u>
            <xsl:apply-templates select="node()|@*"/>
        </u>
    </xsl:template>
    
    <xsl:template match="underline[@underline-style='single']">
        <span style="border-bottom:1px solid">
            <xsl:apply-templates select="node()|@*"/>
        </span>
    </xsl:template>

    <xsl:template match="underline[@underline-style='double']">
        <span style="border-bottom:3px double">
            <xsl:apply-templates select="node()|@*"/>
        </span>
    </xsl:template>

    <xsl:template match="break">
        <br/>
    </xsl:template>

    <!-- preformatted code block -->
    <xsl:template match="preformat | code">
        <pre><code><xsl:apply-templates select="node()|@*"/></code></pre>
    </xsl:template>

    <!-- style elements -->
    <xsl:template match="sc | strike | roman | sans-serif | monospace | overline">
        <span class="{local-name()}">
            <xsl:apply-templates select="node()|@*"/>
        </span>
    </xsl:template>

    <!-- inline elements -->
    <xsl:template
        match="abbrev | suffix | email | year | month | day
        | xref[not(@ref-type=fig)] | contrib | source | volume | fpage | lpage | etal | pub-id
        | named-content | styled-content | funding-source | award-id 
        | institution | city | state | country | addr-line
        | chem-struct">
        <span class="{local-name()}">
            <xsl:apply-templates select="node()|@*"/>
        </span>
    </xsl:template>

    <!-- links -->
    <xsl:template match="uri">
        <a class="{local-name()}">
            <xsl:attribute name="href">
                <xsl:choose>
                    <xsl:when test="@xlink:href">
                        <xsl:value-of select="@xlink:href"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="node()|@*"/>
        </a>
    </xsl:template>

    <!-- table -->
    <xsl:template match="table">
	    <div class="table-container">
		    <xsl:element name="{local-name()}">
	            <xsl:attribute name="class">
	                <xsl:text>table table-bordered table-condensed table-hover</xsl:text>
	                <xsl:if test="@content-type = 'text'">
	                    <xsl:text> table-text</xsl:text>
	                </xsl:if>
	            </xsl:attribute>
	            <xsl:apply-templates select="node()|@*"/>
	        </xsl:element>
	    </div>
    </xsl:template>

    <!-- table elements -->
    <xsl:template match="tbody | thead | tfoot | column | tr | th | td | colgroup | col">
        <xsl:element name="{local-name()}">
            <xsl:if test="@content-type = 'text'">
                <xsl:attribute name="class">table-text</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="table-wrap">
        <figure>
						<xsl:attribute name="class">
							<xsl:value-of select="@class"/><xsl:text> </xsl:text>
							<xsl:value-of select="local-name()"/>
						</xsl:attribute>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="caption" mode="table"/>
            <xsl:apply-templates/>
        </figure>
    </xsl:template>

    <xsl:template match="table-wrap/alternatives">
        <xsl:apply-templates select="table"/>
        <xsl:apply-templates select="../object-id[@pub-id-type='doi']" mode="caption"/>
    </xsl:template>

    <!-- table caption and label are handled elsewhere -->
    <xsl:template match="table-wrap/caption | table-wrap/label"/>

    <xsl:template match="caption" mode="table">
        <div class="{local-name()}">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="preceding-sibling::label" mode="caption"/>
            <xsl:apply-templates select="node()"/>
        </div>
    </xsl:template>

    <xsl:template match="table-wrap-foot/fn/p[normalize-space(.) = 'Notes.']">
        <p class="table-wrap-foot-notes">
            <b>Notes:</b>
        </p>
    </xsl:template>

    <!--<xsl:template match="table/label"></xsl:template>-->

    <!-- label with a paragraph straight afterwards -->
    <!--<xsl:template match="label[following-sibling::p]"></xsl:template>-->

    <!--
    <xsl:template match="label" mode="included-label">
        <span class="article-label">
            <xsl:apply-templates select="node()|@*"/>
        </span>
    </xsl:template>
    -->

    <xsl:template match="p[ancestor::caption][not(ancestor::supplementary-material)]">
        <span class="{local-name()}">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>

    <xsl:template match="fn/p[preceding-sibling::label]">
        <span class="{local-name()}">
            <xsl:apply-templates select="@*"/>
            <!--<xsl:apply-templates select="preceding-sibling::label" mode="included-label"/>-->
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>

    <!-- other object ID -->
    <xsl:template match="object-id"/>

    <!-- sections -->
    <xsl:template match="sec">
        <section class="{local-name()}">
            <xsl:apply-templates select="node()|@*"/>
        </section>
    </xsl:template>

    <!-- section headings -->
    <xsl:template match="title">
        <xsl:variable name="heading-count"
                      select="count(ancestor::sec | ancestor::back | ancestor::fig | ancestor::g) + 1"/>

        <xsl:variable name="heading-level">
            <xsl:choose>
                <xsl:when test="$heading-count > 6">6</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$heading-count"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="heading">h<xsl:value-of select="$heading-level"/></xsl:variable>

        <xsl:element name="{$heading}">
            <xsl:attribute name="class">heading</xsl:attribute>
            <xsl:if test="parent::caption and ancestor::fig">
                <xsl:apply-templates select="../../label" mode="caption"/>
            </xsl:if>
            <xsl:if test="preceding-sibling::label">
                <xsl:apply-templates select="preceding-sibling::label" mode="caption"/>
            </xsl:if>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:element>
    </xsl:template>

    <!-- additional material -->
    <xsl:template match="sec[@sec-type='additional-information']/title">
        <h2 class="heading">
            <xsl:apply-templates select="node()|@*"/>
        </h2>
    </xsl:template>

    <!-- links -->
    <xsl:template match="ext-link">
        <a class="{local-name()}" href="{@xlink:href}" target="_blank">
            <xsl:apply-templates select="node()|@*"/>
        </a>
    </xsl:template>

    <!-- typed links -->
    <xsl:template match="ext-link[@ext-link-type]">
        <xsl:variable name="type" select="@ext-link-type"/>

        <xsl:variable name="url">
            <xsl:choose>
                <xsl:when test="$type = 'uri'">
                    <xsl:value-of select="@xlink:href"/>
                </xsl:when>
                <xsl:when test="$type = 'ftp'">
                    <xsl:value-of select="@xlink:href"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="ext-link-url">
                        <xsl:with-param name="type" select="$type"/>
                        <xsl:with-param name="uri" select="@xlink:href"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <a class="{local-name()}" href="{$url}" target="_blank">
            <xsl:apply-templates select="node()|@*"/>
        </a>
    </xsl:template>

    <!-- map an identifier to an external site -->
    <xsl:template name="ext-link-url">
        <xsl:param name="type"/>
        <xsl:param name="uri"/>

        <xsl:variable name="encoded-id">
            <xsl:call-template name="urlencode">
                <xsl:with-param name="value" select="$uri"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$type = 'doi'">
                <xsl:value-of select="concat('https://doi.org/', $encoded-id)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$uri"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="license-p/ext-link">
        <a class="{local-name()}" href="{@xlink:href}" rel="license">
            <xsl:apply-templates select="node()|@*"/>
        </a>
    </xsl:template>


    <!-- formulae -->
    <xsl:template match="inline-formula">
        <span class="{local-name()}">
            <xsl:apply-templates select="node()|@*"/>
        </span>
    </xsl:template>

    <!-- displ-formula has to be span, as it can appear inside a p -->
    <xsl:template match="disp-formula">
        <span class="{local-name()}">
            <xsl:apply-templates select="node()|@*"/>
        </span>
    </xsl:template>

    <xsl:template match="inline-formula/alternatives">
        <xsl:call-template name="formula-alternatives"/>
    </xsl:template>

    <xsl:template match="disp-formula/alternatives">
        <xsl:call-template name="formula-alternatives"/>
    </xsl:template>

    <!-- choose an appropriate formula representation -->
    <xsl:template name="formula-alternatives">
        <xsl:choose>
            <xsl:when test="mml:math">
                <xsl:apply-templates select="mml:math"/>
            </xsl:when>
            <xsl:when test="inline-graphic">
                <xsl:apply-templates select="inline-graphic"/>
            </xsl:when>
            <xsl:when test="tex-math">
                <xsl:apply-templates select="tex-math"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- math expressed in TeX -->
    <xsl:template match="tex-math">
        <span class="{local-name()}">
            <xsl:value-of select="."/>
        </span>
    </xsl:template>

    <!-- footnote reference -->
    <xsl:template match="xref[@ref-type='fn']">
        <xsl:variable name="footn" select="key('footn', @rid)"/>
		<xsl:variable name="title" select="$footn/p"/>
        <sup>
		<a class="{local-name()} xref-{@ref-type}"  href="#{@rid}" title="{$title}">
           <xsl:apply-templates select="node()|@*"/>
        </a>
		</sup>
    </xsl:template>	
    
    <!-- cross-reference -->
    <xsl:template match="xref">
        <a class="{local-name()} xref-{@ref-type}" href="#{@rid}">
            <xsl:apply-templates select="node()|@*"/>
        </a>
    </xsl:template>

    <!-- Create citations -->
	<xsl:template name="output-tokens">
	    <xsl:param name="list" />
	    <xsl:variable name="newlist" select="concat(normalize-space($list), ' ')" /> 
	    <xsl:variable name="first" select="substring-before($newlist, ' ')" /> 
	    <xsl:variable name="remaining" select="substring-after($newlist, ' ')" /> 
	    
	    <xsl:variable name="ref" select="key('ref', $first)"/>
            <xsl:variable name="citation" select="$ref/element-citation"/>
            <xsl:variable name="authors" select="$ref//name"/>
	    <xsl:variable name="year" select="$ref//year"/>

            <xsl:variable name="url">
                        <xsl:value-of select="concat('#', $citation/../@id)"/>
            </xsl:variable>

	    <a class="{local-name()} xref-{@ref-type}" href="{$url}">
		<xsl:for-each select="$authors">
	    		<xsl:choose>
				<xsl:when test="position() = 1">
					<xsl:value-of select="surname"/>
				</xsl:when>
				<xsl:when test="position() = 2 and position() = last()">
					&amp; <xsl:value-of select="surname"/>
				</xsl:when>
				<xsl:when test="position() = 3"> et al.</xsl:when>
			</xsl:choose>
		</xsl:for-each>, <xsl:value-of select="$year"/>
	    </a><xsl:if test="$remaining">&#59;</xsl:if>
	    <xsl:if test="$remaining">
		<xsl:call-template name="output-tokens">
		    <xsl:with-param name="list" select="$remaining" /> 
		</xsl:call-template>
	    </xsl:if>
	</xsl:template>
	
    <!-- bibliographic reference -->
    <xsl:template match="xref[@ref-type='bibr']">

	<!--The part below had to be removed because otherwise it causes an error -->
        <!--xsl:variable name="title">
            <xsl:choose>
                <xsl:when test="$citation">
					<xsl:apply-templates select="$citation|@*"/>
				
                </xsl:when>
            </xsl:choose>
        </xsl:variable-->
		
	   <!--xsl:apply-templates select="node()|@*"/-->
           <!--xsl:call-template name="output-tokens">
		<xsl:with-param name="list" select="@rid" />
	   </xsl:call-template-->
			<xsl:variable name="ref" select="key('ref', @rid)"/>
      <xsl:variable name="year" select="$ref//year"/>
			<xsl:variable name="citation" select="$ref/element-citation"/>
			<xsl:variable name="url">
      	<xsl:value-of select="concat('#', $citation/../@id)"/>
      </xsl:variable>

			<a class="{local-name()} xref-{@ref-type}" href="{$url}">
				<xsl:choose>
					<xsl:when test="$year">
						<xsl:value-of select="$year"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>o.J.</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</a>
    </xsl:template>

    <!-- figure -->
    <xsl:template match="fig">
        <figure class="{local-name()}" itemprop="image" itemscope="itemscope" itemtype="https://schema.org/ImageObject">
            <xsl:apply-templates select="@*"/>

            <div class="image-container">
                <xsl:apply-templates select="graphic" mode="fig"/>
            </div>

            <xsl:apply-templates select="caption" mode="fig"/>

            <xsl:apply-templates select="p"/>

            <xsl:apply-templates select="media" mode="fig"/>
        </figure>
    </xsl:template>

    <!-- figure caption -->
    <xsl:template match="caption" mode="fig">
				<xsl:if test=". != ''">
        <figcaption itemprop="description">
            <!--xsl:if test="not(title)"-->
                <xsl:apply-templates select="preceding-sibling::label" mode="caption"/>
            <!--/xsl:if-->

            <!--xsl:apply-templates select="node()|@*"/-->
						<xsl:call-template name="figcaption-title" mode="caption"/>

            <div class="figcaption-footer">
                <xsl:apply-templates select="../object-id[@pub-id-type='doi']" mode="caption"/>
            </div>
        </figcaption>
				</xsl:if>
    </xsl:template>

		<xsl:template name="figcaption-title">
			<span class="fig-label">
				<xsl:apply-templates select="title" mode="fig"/>
			</span>
		</xsl:template>

    <!-- DOI in a caption -->
    <xsl:template match="object-id[@pub-id-type='doi']" mode="caption">
        <div class="{local-name()} article-component-doi">
            <xsl:text>DOI:&#32;</xsl:text>
            <a href="{concat('https://doi.org/', .)}" data-toggle="tooltip" title="Cite this object using this DOI">
                <xsl:value-of select="."/>
            </a>
        </div>
    </xsl:template>

    <!-- figure title -->
    <xsl:template match="title[ancestor::table-wrap]">
        <div class="{local-name()}">
            <xsl:apply-templates select="node()|@*"/>
        </div>
    </xsl:template>

    <!-- figure title -->
    <xsl:template match="title" mode="fig">
        <div class="{local-name()}">
            <xsl:apply-templates select="node()|@*"/>
        </div>
    </xsl:template>

    <!-- graphic -->
    <xsl:template match="graphic | inline-graphic">
        <img class="{local-name()}" src="{$static-root}{@xlink:href}" data-filename="{@xlink:href}">
					<xsl:apply-templates select="@*"/>
        </img>
    </xsl:template>

    <!-- figure graphic -->
    <!-- TODO: image width and height -->
    <xsl:template match="graphic" mode="fig">
        <xsl:variable name="fig" select=".."/>
        <xsl:variable name="fig-id" select="$fig/@id"/>
        <xsl:variable name="root" select="concat($static-root, @xlink:href)"/>
				<xsl:variable name="fig-alt-text" select="$fig/alt-text"/>
				<xsl:variable name="classes" select="$fig/graphic/@class"/>
				<div
           title=""
           data-fresco-caption="{$fig/label}: {$fig/caption/title}">
	        <img class="{local-name()} {$classes}"
	             src="{$root}"
	             itemprop="contentUrl"
	             data-image-id="{$fig-id}"
	             alt="{$fig-alt-text}"
	             data-image-type="figure">
						<xsl:if test="$classes">
						</xsl:if>
						<xsl:apply-templates select="@*"/>
	        </img>
        </div>
    </xsl:template>

    <!-- figure video -->
    <xsl:template match="media[@mimetype='video']" mode="fig">
        <div class="{local-name()}">
            <xsl:apply-templates select="@*"/>

            <a href="{$static-root}{@xlink:href}"
               class="btn btn-mini article-supporting-download"
               data-rel="supplement"
               download="{@xlink:href}"
               data-filename="{@xlink:href}">
                <i class="icon-large icon-facetime-video">&#160;</i>
                <xsl:text>Download video</xsl:text>
            </a>
        </div>
        <!--
        <video controls="controls" preload="none" width="100%">
            <source src="{$static-root}{@xlink:href}" type="video/{@mime-subtype}"/>
        </video>
        -->
    </xsl:template>

    <!-- definition list -->
    <xsl:template match="def-list">
        <dl>
            <xsl:apply-templates select="node()|@*"/>
        </dl>
    </xsl:template>

    <xsl:template match="def-item">
        <xsl:apply-templates select="term" mode="def-item"/>
        <xsl:apply-templates select="def" mode="def-item"/>
    </xsl:template>

    <xsl:template match="term" mode="def-item">
        <dt>
            <xsl:apply-templates select="node()|@*"/>
        </dt>
    </xsl:template>

    <xsl:template match="def" mode="def-item">
        <dd>
            <xsl:apply-templates select="node()|@*"/>
        </dd>
    </xsl:template>

    <!-- TODO -->
    <xsl:template match="list-item/label"/>

    <!-- supplementary material -->
    <xsl:template match="supplementary-material">
        <div class="{local-name()} well well-small">
            <xsl:apply-templates select="@*"/>
            <h3 class="heading">
                <!--<xsl:apply-templates select="label/text()"/>-->
                <xsl:choose>
                    <xsl:when test="normalize-space(caption/title) != ''">
                        <xsl:apply-templates select="caption/title" mode="supp-title"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="label"/>
                    </xsl:otherwise>
                </xsl:choose>
            </h3>

            <xsl:apply-templates select="caption"/>

            <xsl:apply-templates select="object-id[@pub-id-type='doi']" mode="caption"/>

	    <!--<xsl:apply-templates select="." mode="file-viewer"/>-->

            <xsl:call-template name="supplemental-file-download">
                <xsl:with-param name="filename" select="@xlink:href"/>
            </xsl:call-template>
        </div>
    </xsl:template>

	<!--
	<xsl:template match="supplementary-material[@mimetype='video']" mode="file-viewer">
		<video controls="controls" preload="none" width="100%">
			<source src="{$static-root}{@xlink:href}" type="video/{@mime-subtype}"/>
		</video>
	</xsl:template>
	-->

    <xsl:template name="supplemental-file-download">
        <xsl:param name="filename"/>

        <xsl:variable name="encoded-filename">
            <xsl:call-template name="urlencode">
                <xsl:with-param name="value" select="$filename"/>
            </xsl:call-template>
        </xsl:variable>

        <div>
            <a href="{$static-root}{$encoded-filename}" class="btn article-supporting-download"
               data-rel="supplement" download="{$filename}" data-filename="{$filename}">
                <i class="icon-large icon-download-alt">&#160;</i>
                <!--<xsl:value-of select="concat(' Download .', ../@mime-subtype)"/>-->
                <xsl:value-of select="' Download'"/>
            </a>
        </div>
    </xsl:template>

    <xsl:template match="supplementary-material/caption">
        <xsl:apply-templates select="node()|@*"/>
    </xsl:template>

    <xsl:template match="supplementary-material/caption/title"/>

    <xsl:template match="supplementary-material/caption/title" mode="supp-title">
        <!--<xsl:text>:&#32;</xsl:text>-->
        <xsl:apply-templates select="node()"/>
    </xsl:template>

    <!-- text box -->
    <xsl:template match="boxed-text">
        <aside class="{local-name()}">
            <xsl:apply-templates select="node()|@*"/>
        </aside>
    </xsl:template>

    <!-- acknowledgments -->
    <xsl:template match="ack">
        <section class="{local-name()}" id="acknowledgements">
            <xsl:apply-templates select="@*"/>
            <h2 class="heading">Acknowledgements</h2>
            <xsl:apply-templates select="node()"/>
        </section>
    </xsl:template>

    <!-- glossary -->
    <xsl:template match="glossary">
        <section class="{local-name()}">
            <xsl:apply-templates select="node()|@*"/>
        </section>
    </xsl:template>

    <!-- appendices -->
    <xsl:template match="app-group">
        <xsl:apply-templates select="app"/>
    </xsl:template>

    <!-- appendix -->
    <xsl:template match="app">
        <section class="{local-name()}">
            <xsl:apply-templates select="node()|@*"/>
        </section>
    </xsl:template>

    <!-- appendix label -->
    <xsl:template match="app/label">
        <h2 class="heading">
            <xsl:apply-templates/>
        </h2>
    </xsl:template>

	<!-- empty appendix title -->
	<xsl:template match="app/title[.='']"/>

    <!-- appendix title -->
    <xsl:template match="app/title">
	    <xsl:choose>
	        <xsl:when test="../label">
			    <h3 class="heading">
				    <xsl:apply-templates/>
			    </h3>
	        </xsl:when>
		    <xsl:otherwise>
			    <h2 class="heading">
				    <xsl:apply-templates/>
			    </h2>
		    </xsl:otherwise>
	    </xsl:choose>
    </xsl:template>

	<!-- statement label (inline, bold) -->
	<xsl:template match="statement/label">
		<b class="statement-label">
			<xsl:apply-templates/>
		</b>
	</xsl:template>

	<!-- assumption label (block, italic) -->
	<xsl:template match="statement[@content-type='assumption']/label">
		<i class="statement-label-assumption">
			<xsl:apply-templates/>
		</i>
	</xsl:template>

	<!-- proof label (inline, italic) -->
	<xsl:template match="statement[@content-type='proof']/label">
		<i class="statement-label-proof">
			<xsl:apply-templates/>
		</i>
	</xsl:template>

    <!-- reference list -->
    <xsl:template match="ref-list">		
			<h3 id="literatur-liste">Literatur</h3>
        <section class="ref-list-container" id="references">
            <ol class="{local-name()}">
								<xsl:for-each select="ref">
									<xsl:sort select=".//person-group[@person-group-type='author']/name[1]/surname | .//person-group[@person-group-type='editor']/name/surname | .//person-group/collab/named-content"/>
									<xsl:sort select=".//person-group[@person-group-type='author']/name[2]/surname"/>
									<xsl:sort select=".//person-group[@person-group-type='author']/name[3]/surname"/>
									<xsl:sort select=".//year" order="ascending"/>
									<xsl:sort select="count(.//person-group[@person-group-type='author']/name/surname)" order="ascending"/>
									<xsl:call-template name="ref"/>
								</xsl:for-each>
            </ol>
        </section>
    </xsl:template>

    <!-- reference list item -->
    <xsl:template name="ref">
			<xsl:variable name="search-string" select="'span'"/>
    	<xsl:if test="key('bibrefs', @id)">
				<li id="{@id}" class="{local-name()}">
            <div class="citation" itemprop="citation" itemscope="itemscope">
                <xsl:choose>
                    <xsl:when test="element-citation/@publication-type = 'journal'">
                        <xsl:attribute name="itemtype">http://schema.org/ScholarlyArticle</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="element-citation/@publication-type = 'webpage'">
                        <xsl:attribute name="class">citation webpage</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="itemtype">http://schema.org/Book</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
									
								<xsl:choose>
									<xsl:when test="element-citation/person-group[@person-group-type='author']/name">
										<xsl:for-each select="element-citation/person-group[@person-group-type='author']/name">
											<xsl:call-template name="ampersand-separator"/>
											<span>
												<xsl:call-template name="ref-author-name"/>
											</span> 
											<xsl:call-template name="comma-separator"/>
										</xsl:for-each>
									</xsl:when>
									<xsl:when test="element-citation/person-group[@person-group-type='author']/collab">
										<xsl:value-of select="element-citation/person-group[@person-group-type='author']/collab/named-content"/>
									</xsl:when>
									<xsl:when test="element-citation[@publication-type='webpage'] and not(element-citation/person-group[@person-group-type='author'])">
									</xsl:when>
									<xsl:otherwise>
	                  <xsl:for-each select="element-citation/person-group[@person-group-type='editor']/name">
                    <xsl:call-template name="ampersand-separator"/>
                    <span>
											<xsl:call-template name="ref-author-name"/>
										</span> 
                    <xsl:call-template name="comma-separator"/>
                  </xsl:for-each>
									<xsl:text> (Hrsg.). </xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							
								<xsl:choose>
								<!-- A year declaration with 'o.J' (ohne Jahrgang) is not displayed -->
								<xsl:when test="element-citation/year and element-citation/year!='o.J.'">
									<xsl:text> (</xsl:text>
									<span class="year" itemprop="year"><xsl:value-of select="element-citation/year"/></span>
									<xsl:text>). </xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text> </xsl:text>
								</xsl:otherwise>
								</xsl:choose>
								<span class="title">
								<xsl:call-template name="remove-span-string">
										<xsl:with-param name="elem-with-span" select="element-citation/article-title"/>
									</xsl:call-template>
								</span>
									<xsl:call-template name="remove-span-string">
										<xsl:with-param name="elem-with-span" select="element-citation/chapter-title"/>
									</xsl:call-template>
	
								<xsl:if test="element-citation/article-title or element-citation/chapter-title or element-citation[@publication-type='webpage']">. </xsl:if>
								<xsl:if test="element-citation/person-group[@person-group-type='editor'] and element-citation/person-group[@person-group-type='author']">
									<xsl:text>In </xsl:text>
									<xsl:for-each select="element-citation/person-group[@person-group-type='editor']/name">
										<xsl:call-template name="ampersand-separator"/>
										<span><!--xsl:call-template name="ref-author-name"/-->
											<xsl:value-of select="given-names"/><xsl:text> </xsl:text><xsl:value-of select="surname"/>
										</span> 
                    	<xsl:call-template name="comma-separator"/>
									</xsl:for-each>
									<xsl:text> (Hrsg.), </xsl:text>
								</xsl:if>
								<i><xsl:call-template name="remove-span-string">
									<xsl:with-param name="elem-with-span" select="element-citation/source"/>
								</xsl:call-template></i>
								<xsl:choose>
								<xsl:when test="element-citation/@publication-type = 'journal'">
									<xsl:text>, </xsl:text>
								</xsl:when>
								<xsl:when test="element-citation/@publication-type = 'book'">
									<xsl:choose>
										<xsl:when test="element-citation/page-range">
											<xsl:text> </xsl:text>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>. </xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text> </xsl:text>
								</xsl:otherwise>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="element-citation/@publication-type = 'journal'">
										<span class="volume" itemprop="volume"><xsl:value-of select="element-citation/volume"/></span>
										<xsl:choose>
											<xsl:when test="element-citation/issue">
												<xsl:text>(</xsl:text>
												<span class="issue" itemprop="issue">
													<xsl:value-of select="element-citation/issue"/>
												</span>
												<xsl:text>)</xsl:text>
												<xsl:choose>
													<xsl:when test="element-citation/page-range">
														<xsl:text>, </xsl:text>
													</xsl:when>
													<xsl:otherwise>
														<xsl:text>. </xsl:text>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:when>
											<xsl:otherwise>
												<xsl:choose>
													<xsl:when test="element-citation/page-range">
														<xsl:text>, </xsl:text>
													</xsl:when>
													<xsl:otherwise>
														<xsl:text>. </xsl:text>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:otherwise>
										</xsl:choose>
										<xsl:if test="element-citation/page-range">
											<xsl:text> </xsl:text>
											<xsl:value-of select="element-citation/page-range"/>
											<xsl:if test="element-citation/uri">
												<xsl:text>. </xsl:text>
											</xsl:if>
										</xsl:if>
									</xsl:when>
									<xsl:when test="element-citation/@publication-type != 'journal'">
										<xsl:if test="element-citation/volume">
											<xsl:text>(</xsl:text>
											<xsl:value-of select="element-citation/volume"/>
											<xsl:text>)</xsl:text>
										</xsl:if>
										<xsl:if test="element-citation/page-range">
											<xsl:text>(S. </xsl:text>
											<xsl:value-of select="element-citation/page-range"/>
											<xsl:text>)</xsl:text>
											<xsl:if test="element-citation/publisher-loc">
												<xsl:text>. </xsl:text>
											</xsl:if>
										</xsl:if>
									</xsl:when>
								</xsl:choose>
								<xsl:value-of select="element-citation/publisher-loc"/>
								<xsl:if test="element-citation/publisher-name and element-citation/publisher-loc">
									<xsl:text>: </xsl:text>
								</xsl:if>
								<xsl:value-of select="element-citation/publisher-name"/>
								<xsl:if test="element-citation/publisher-name and element-citation/uri">
									<xsl:text>. </xsl:text>
								</xsl:if>
								<xsl:if test="element-citation/uri">
									<xsl:text>Abgerufen	</xsl:text>		
									<xsl:if test="element-citation/date-in-citation">
										<xsl:text>am </xsl:text><xsl:value-of select="translate(element-citation/date-in-citation, '-', '.')"/><xsl:text> </xsl:text>
									</xsl:if> 
									<xsl:text>unter: </xsl:text><a href="{element-citation/uri}" target="_blank"><xsl:value-of select="element-citation/uri"/></a>
								</xsl:if>
								<xsl:if test="element-citation/pub-id[@pub-id-type='doi'] and element-citation/pub-id[@pub-id-type='doi'] != '10.123/doi-nicht-vorhanden'">
									<xsl:variable name="doi-url" select="element-citation/pub-id[@pub-id-type='doi']"/>
									<xsl:text>. doi:&#8239;</xsl:text><a href="https://doi.org/{$doi-url}" target="_blank"><xsl:value-of select="$doi-url"/></a>
								</xsl:if>
								<xsl:text>.</xsl:text>
            </div>
        </li>
			</xsl:if>
    </xsl:template>

		<xsl:template name="remove-span-string">
			<xsl:param name="elem-with-span"/>
			<xsl:variable name="modified-elem">
        <xsl:call-template name="string-replace-all">
					<xsl:with-param name="text" select="$elem-with-span" />
					<xsl:with-param name="replace" select="'&lt;span class=&quot;nocase&quot;&gt;'" />
					<xsl:with-param name="by" select="''" />
				</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="correct-elem">
				<xsl:call-template name="string-replace-all">
					<xsl:with-param name="text" select="$modified-elem" />
					<xsl:with-param name="replace" select="'&lt;/span&gt;'" />
					<xsl:with-param name="by" select="''" />
				</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="$correct-elem"/>
		</xsl:template>

		<xsl:template name="string-replace-all">
    <xsl:param name="text" />
    <xsl:param name="replace" />
    <xsl:param name="by" />
    <xsl:choose>
      <xsl:when test="contains($text, $replace)">
        <xsl:value-of select="substring-before($text,$replace)" />
        <xsl:value-of select="$by" />
        <xsl:call-template name="string-replace-all">
          <xsl:with-param name="text"
          select="substring-after($text,$replace)" />
          <xsl:with-param name="replace" select="$replace" />
          <xsl:with-param name="by" select="$by" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

    <xsl:template name="ref-author-name">
        <xsl:if test="surname">
            <xsl:apply-templates select="surname"/>
        </xsl:if>
        <xsl:if test="suffix">
            <xsl:text>&#32;</xsl:text>
            <xsl:apply-templates select="suffix"/>
        </xsl:if>
        <xsl:text>, </xsl:text>
        <xsl:apply-templates select="given-names"/>
    </xsl:template>
    <!-- "et al" -->
    <xsl:template match="person-group/etal">
        <span class="{local-name()}">et al.</span>
    </xsl:template>

    <!-- block elements -->
    <xsl:template match="*">
        <div class="{local-name()}">
            <xsl:apply-templates select="node()|@*"/>
        </div>
    </xsl:template>

    <!-- attributes to copy directly -->
    <xsl:template match="@id | @colspan | @rowspan | @style">
        <xsl:copy-of select="."/>
    </xsl:template>

    <!-- attributes that should be styles -->
    <xsl:template match="@valign">
        <xsl:call-template name="add-style">
            <xsl:with-param name="style" select="concat('vertical-align:', .)"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="@align">
        <xsl:call-template name="add-style">
            <xsl:with-param name="style" select="concat('text-align:', .)"/>
        </xsl:call-template>
    </xsl:template>

    <!-- even though it's deprecated, need these -->
    <xsl:template match="colgroup/@valign | colgroup/@align | col/@valign | col/@align">
        <xsl:copy-of select="."/>
    </xsl:template>

    <!-- add to the style attribute -->
    <xsl:template name="add-style">
        <xsl:param name="style"/>
        <xsl:attribute name="style">
            <xsl:value-of select="normalize-space(concat(@style, ' ', $style, ';'))"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="@sec-type">
        <xsl:attribute name="id">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>

    <!-- other attributes (ignore) -->
    <xsl:template match="@*">
        <xsl:attribute name="data-jats-{local-name()}">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>

    <!-- ignore namespaced attributes -->
    <xsl:template match="@*[namespace-uri()]"/>

    <!-- mathml root element -->
    <xsl:template match="mml:math">
        <math xmlns="http://www.w3.org/1998/Math/MathML">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="mathml"/>
        </math>
    </xsl:template>

    <!-- mathml (direct copy) -->
    <xsl:template match="*" mode="mathml">
        <xsl:element name="{local-name()}" xmlns="http://www.w3.org/1998/Math/MathML">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="mathml"/>
        </xsl:element>
        <!--<xsl:copy-of select="."/>-->
    </xsl:template>
</xsl:stylesheet>
