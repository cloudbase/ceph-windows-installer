<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:wix="http://schemas.microsoft.com/wix/2006/wi">

<xsl:output method="xml" indent="yes" />

<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<xsl:key name="rbd-nbd-search" match="wix:Component[contains(wix:File/@Source, 'rbd-nbd.exe')]" use="@Id" />
<xsl:template match="wix:Component[key('rbd-nbd-search', @Id)]" />

</xsl:stylesheet>