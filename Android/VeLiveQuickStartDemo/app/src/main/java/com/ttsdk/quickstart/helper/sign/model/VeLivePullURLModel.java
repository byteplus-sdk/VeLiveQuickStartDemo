/**
 * Copyright (c) 2023 BytePlus Pte. Ltd. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
package com.ttsdk.quickstart.helper.sign.model;

import com.google.gson.annotations.SerializedName;

import java.util.ArrayList;

public class VeLivePullURLModel {
    @SerializedName("URLList")
    public ArrayList<VeLivePullURLListModel> urlList;
    public String getUrl(String protocol) {
        if (urlList == null || urlList.isEmpty()) {
            return null;
        }
        String url = null;
        for (VeLivePullURLListModel model: urlList) {
            if (model.protocol.equals(protocol)) {
                url = model.url;
                break;
            }
        }
        return url;
    }
}
