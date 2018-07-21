import { h } from "virtual-dom";
import attributeHook from "discourse/lib/attribute-hook";

const SVG_NAMESPACE = "http://www.w3.org/2000/svg";
const ICON_PATH = "/assets/sprites/solid.svg";

function svgPathFor(icon) {
  let id = icon.replacementId || icon.id || "";
  if (id.indexOf("svg-") === 0) {
    id = id
      .replace("svg-", "Icon_")
      .replace(/\-/g, "_")
      .replace(/ .*$/, "");
  }

  return Discourse.getURL(`${ICON_PATH}#${id}`);
}

function iconClasses(id, opts) {
  let classes = `d-icon d-icon-${id.replace(/\./, "-")}`;
  if (opts.class) {
    classes += ` ${opts.class}`;
  }
  return classes;
}

export default {
  name: "svg-icons",

  string(icon, opts) {
    let id = icon.id || "";
    let classes = iconClasses(id, opts);

    const href = svgPathFor(icon);
    classes += " svg-icon";
    return `<svg class="${classes}" xmlns="${SVG_NAMESPACE}" version="1.1"><use xlink:href="${href}" /></svg>`;
  },

  node(icon, opts) {
    let id = icon.id || "";
    let classes = iconClasses(id, opts);

    const href = svgPathFor(icon);

    classes += " svg-icon";
    return h(
      "svg",
      {
        attributes: { class: classes },
        namespace: SVG_NAMESPACE
      },
      [
        h("use", {
          "xlink:href": attributeHook("http://www.w3.org/1999/xlink", href),
          namespace: SVG_NAMESPACE
        })
      ]
    );
  }
};
