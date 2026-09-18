FROM docker.io/frappe/erpnext:v16.34.1@sha256:eee240a179ff494cb82ad067d853c8db3f87171d86324f4b326892654e342144

USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends supervisor \
    && rm -rf /var/lib/apt/lists/*

USER frappe
WORKDIR /home/frappe/frappe-bench
# Optional comma-separated apps, each as <git-url>@<branch>. Empty installs vanilla Frappe only.
ARG FRAPPE_APPS=""
RUN if [ -n "$FRAPPE_APPS" ]; then \
      for app in $(echo "$FRAPPE_APPS" | tr ',' ' '); do \
        url="${app%@*}"; branch="${app##*@}"; \
        if [ "$branch" = "$url" ]; then branch="version-16"; fi; \
        bench get-app --branch "$branch" "$url"; \
      done; \
    fi \
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
