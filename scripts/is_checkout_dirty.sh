# Copyright 2018 The SET Team Authors
# This file is part of the SET project.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

#!/usr/bin/env bash
# Gives us a non-zero exit code if there are tracked or untracked changes in the working
# directory
export stat=$(git status --porcelain)
[[ -z "$stat" ]] || (echo "Dirty checkout:" && echo "$stat" && exit 1)

