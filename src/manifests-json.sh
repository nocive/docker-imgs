#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

function fn.usage() {
	echo "Usage: $0 ls|push"
	echo
	echo "  ls     Lists the manifests information found in bake build metadata files."
	echo "  push   Creates and pushes the manifests from found bake build metadata files."
}

function fn.uuidgen() {
	uuidgen -r
}

function fn.manifests_list() {
	jq -sM \
		--arg uuid "$(fn.uuidgen)" \
		'
			[.[][]] | reduce .[] as $item (
				{};
				($item["buildx.build.provenance"]["invocation"]["parameters"]["args"]["label:docker.basetag"] // "") as $basetag |
				if $item != null then
					.[$item["image.name"] + ":" + (if $basetag == "" then $uuid else $basetag + "-" + $uuid end)] += [$item["image.name"] + "@" + $item["containerimage.digest"]]
				else
					empty
				end
			)
		' .bake_build_*.json
}

function fn.must_have_build_metadata_files() {
	local check=(.bake_build_*.json)
	if [ "${#check[*]}" -lt 1 ]; then
		echo "No bake build metadata files found in current directory '$PWD'." >&2
		echo "Did you perhaps forget to build?" >&2
		exit 1
	fi
}

if [ $# -lt 1 ]; then
	echo "Not enough arguments provided!" >&2
	exit 1
fi

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	fn.usage
	exit 0
fi

case "$1" in
ls|list)
	fn.must_have_build_metadata_files
	fn.manifests_list
	;;
push)
	fn.must_have_build_metadata_files
	manifests="$(fn.manifests_list)"
	printf "%s\n" "$manifests"
	jq -crM '. | to_entries[] | "docker buildx imagetools create -t \(.key) \(.value|join(" "))"' <<< "$manifests" | xargs -r -I {} -t sh -c '{}'
	printf "%s\n" "$manifests" > manifest.json
	;;
*)
	echo "Invalid action provided!" >&2
	fn.usage
	exit 1
esac
