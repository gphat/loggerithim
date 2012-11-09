<?xml version='1.0'?>

<!-- $Id: loggerStyle.xsl,v 1.7 2003/06/20 19:26:43 cwatson Exp $ -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
				version="1.0">

<xsl:import href="/opt/docbook-xsl/xhtml/docbook.xsl" />

<xsl:param name="admin.graphics" select="1" />
<xsl:param name="footnote.number.format" select="1" />
<xsl:param name="fop.extensions" select="1" />
<xsl:param name="shade.verbatim" select="1" />
<xsl:param name="title.margin.left" select="'0pt'" />
<xsl:param name="ulink.footnotes" select="1" />
<xsl:param name="ulink.footnote.number.format" select="1" />

<xsl:param name="output.media" select="'print'" />
<xsl:param name="output.type" select="'expanded'" />
<xsl:param name="toc.section.depth" select="1" />

<xsl:attribute-set name="section.title.properties">
 <xsl:attribute name="font-style">italic</xsl:attribute>
</xsl:attribute-set>

<xsl:template match="para[@role='summarization']">
 <fo:block font-size="14pt" font-style="italic">
  <xsl:apply-templates />
 </fo:block>
</xsl:template>

<xsl:template math="title" mode="book.titlepage.recto.mode">
 <fo:block font-size="24.8832pt" fo:font-family="{$title.font.family}">
  <xsl:apply-templates />
  <xsl:apply-templates select="../subtitle[1]" mode="book.titlepage.recto.mode" />
 </fo:block>
</xsl:template>

</xsl:stylesheet>
