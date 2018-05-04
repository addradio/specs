<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml">

    <xsl:output encoding="UTF-8" method="text" />

    <xsl:template match="/book">
        <xsl:for-each select="chapter">
            <xsl:text>chapter_</xsl:text>
            <xsl:number/>
            <xsl:text>&#x0A;</xsl:text>
        </xsl:for-each>
        <xsl:for-each select="appendix">
            <xsl:text>appendix_</xsl:text>
            <xsl:number/>
            <xsl:text>&#x0A;</xsl:text>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
