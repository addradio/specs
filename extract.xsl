<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml">

    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

    <xsl:template match="/book">
        <xsl:param name="node" select="$type" />
        <xsl:param name="idx" select="$index" />
        <xsl:copy select=".">
            <xsl:copy-of select="title" />
            <xsl:copy-of select="node()[name() = $node][position() = $idx]" />
            <a select="{$node}[{$idx}]" />
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
