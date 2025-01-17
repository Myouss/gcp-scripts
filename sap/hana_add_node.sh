#!/bin/bash 
# ------------------------------------------------------------------------
# Copyright 2018 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Description:  
# ------------------------------------------------------------------------

source hana_operations.sh

hana_operations::stop_db
hana_operations::exportfs
hana_operations::mount_shared
hana_operations::copy_public_key_to_worker
hana_operations::start_db
hana_operations::add_node
