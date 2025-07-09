# In roles/shipping/tasks/main.yaml

# ... (previous tasks like 'Build application with Maven')

- name: Load the initial database schema
  ansible.builtin.shell: "mysql -h {{ mysql_host }} -uroot -pRoboShop@1 < /app/db/schema.sql"
  # Using root here to create the 'cities' database initially

# --- THIS IS THE NEW TASK TO ADD ---
- name: Ensure the shipping database table is correctly named 'codes'
  ansible.builtin.script:
    cmd: rename_shipping_table.sh
    executable: /bin/bash # Explicitly tell it to use bash

- name: Load master data into the 'codes' table
  ansible.builtin.shell: "mysql -h {{ mysql_host }} -uroot -pRoboShop@1 cities < /app/db/master-data.sql"
  # Now this should work correctly.

# ... (your other tasks like reload-restart)