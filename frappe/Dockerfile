FROM docker.io/frappe/erpnext:v16.34.1@sha256:eee240a179ff494cb82ad067d853c8db3f87171d86324f4b326892654e342144

USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends supervisor \
    && rm -rf /var/lib/apt/lists/*

USER frappe
WORKDIR /home/frappe/frappe-bench
# Optional comma-separated apps, each as <git-url>@<branch>. Empty installs vanilla Frappe only.
# Repos already in apps/ (erpnext ships in the base image) reuse the pinned copy; get-app would prompt and abort.
# frappe_apps.txt records real app dir names (repo name can differ) for install-app on boot.
ARG FRAPPE_APPS=""
RUN touch frappe_apps.txt \
    && for app in $(echo "$FRAPPE_APPS" | tr ',' ' '); do \
      url="${app%@*}"; branch="${app##*@}"; \
      if [ "$branch" = "$url" ]; then branch="version-16"; fi; \
      repo="$(basename "${url%.git}")"; \
      if [ -d "apps/$repo" ]; then echo "$repo" >> frappe_apps.txt; continue; fi; \
      ls -1 apps > /tmp/apps.before; \
      bench get-app --skip-assets --branch "$branch" "$url" || exit 1; \
      ls -1 apps | grep -vxFf /tmp/apps.before >> frappe_apps.txt || true; \
    done \
    && bench build \
    && grep -Fq '"website.bundle.css"' sites/assets/assets.json \
    && rm -rf /home/frappe/frappe-bench/assets \
    && cp -r /home/frappe/frappe-bench/sites/assets /home/frappe/frappe-bench/assets

USER root
COPY entrypoint.sh /usr/local/bin/frappe-entrypoint
COPY supervisord.conf /etc/supervisor/conf.d/frappe.conf
RUN chmod 755 /usr/local/bin/frappe-entrypoint

ENV PORT=8080
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/frappe-entrypoint"]
