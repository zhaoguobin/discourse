import svgIconRenderer from "discourse/lib/svg-icon-renderer";
import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "svg-icons",

  initialize() {
    withPluginApi("0.8.11", api => {
      api.registerIconRenderer(svgIconRenderer);
      //api.replaceIcon("caret-right", "Icon_chevron_right");
    });
  }
};
