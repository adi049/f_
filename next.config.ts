import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: "export",
  basePath: "/f_",
  trailingSlash: true,
  images: {
    unoptimized: true,
  },
};

export default nextConfig;
