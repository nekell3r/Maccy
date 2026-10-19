#!/usr/bin/env python3
"""Create the fork's Sparkle feed from a packaged release and its signature."""

import email.utils
import os
from pathlib import Path
import plistlib
import xml.etree.ElementTree as ET

namespace = "http://www.andymatuschak.org/xml-namespaces/sparkle"
ET.register_namespace("sparkle", namespace)
app = Path("build/Build/Products/Release/Maccy.app")
info = plistlib.loads((app / "Contents/Info.plist").read_bytes())
version = info["CFBundleShortVersionString"]
release = f"https://github.com/nekell3r/Maccy/releases/tag/v{version}"
rss = ET.Element("rss", version="2.0")
channel = ET.SubElement(rss, "channel")
ET.SubElement(channel, "title").text = "Maccy image history fork"
ET.SubElement(channel, "link").text = "https://github.com/nekell3r/Maccy/releases"
ET.SubElement(channel, "description").text = "Signed updates for the nekell3r/Maccy fork."
item = ET.SubElement(channel, "item")
ET.SubElement(item, "title").text = f"Maccy {version}"
ET.SubElement(item, "link").text = release
ET.SubElement(item, "pubDate").text = email.utils.formatdate(usegmt=True)
ET.SubElement(item, f"{{{namespace}}}version").text = info["CFBundleVersion"]
ET.SubElement(item, f"{{{namespace}}}shortVersionString").text = version
ET.SubElement(item, f"{{{namespace}}}minimumSystemVersion").text = "14.0.0"
ET.SubElement(item, "description").text = "Image history improvements and application fixes."
ET.SubElement(item, "enclosure", {
    "url": f"https://github.com/nekell3r/Maccy/releases/download/v{version}/Maccy.app.zip",
    f"{{{namespace}}}edSignature": os.environ["UPDATE_SIGNATURE"],
    "length": str(Path("dist/Maccy.app.zip").stat().st_size),
    "type": "application/octet-stream",
})
ET.indent(rss)
ET.ElementTree(rss).write("dist/appcast.xml", encoding="utf-8", xml_declaration=True)
