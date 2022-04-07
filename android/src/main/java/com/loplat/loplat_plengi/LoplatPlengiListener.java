package com.loplat.loplat_plengi;

import android.content.Context;
import android.os.Build;
import android.util.Log;

import com.google.gson.Gson;
import com.loplat.placeengine.PlengiResponse;

/**
 * Created by sebastian song on 20. 5. 13.
 */
public class LoplatPlengiListener implements com.loplat.placeengine.PlengiListener {
    private static final String TAG = LoplatPlengiListener.class.getSimpleName();
    private Context mContext;
    public LoplatPlengiListener(Context context) {
        mContext = context;
    }

    @Override
    public void listen(PlengiResponse response) {
        Log.i(TAG, "LoplatPlengiListener: " + response.type);
        Context context = mContext;
        /*String description;
        Intent i = new Intent();
        i.setPackage(context.getPackageName());
        if(response.result < PlengiResponse.Result.SUCCESS) {
            description = getFailResponseToDescription(context, response);
        } else {
            description = getResponseToDescription(context, response);
        }*/
        //int msg = 1809;
        //FlutterBackgroundExecutor.getInstance().forwardMessageToFlutter(context, msg);
        FlutterBackgroundExecutor.getInstance().forwardMessageToFlutter(context, new Gson().toJson(response));
    }

    public static String getFailResponseToDescription(Context context, PlengiResponse response) {
        String description = "";
        if (response.result < PlengiResponse.Result.SUCCESS) {
            if (response.result == PlengiResponse.Result.ERROR_CLOUD_ACCESS) {
                description += "cloud access error: " + response.errorReason;
            } else {
                description += "response fail: " + response.errorReason;
            }
            if (response.advertisement != null) {
                description += "\n   AD)" + response.advertisement.getCampaign_id() + ":" + response.advertisement.getTitle();
            }
        }
        return description;
    }

    public static String getResponseToDescription(Context context, final PlengiResponse response) {
        String description = "";
        int event = response.placeEvent;
        if (response.type == PlengiResponse.ResponseType.PLACE) {
            if (response.place != null) {
                description += "@";
                if (response.place.accuracy > response.place.threshold) {
                    description += "[ENTER]";
                } else {
                    description += "[NEARBY]";
                }
            }
        } else if (response.type == PlengiResponse.ResponseType.PLACE_EVENT
                || response.type == PlengiResponse.ResponseType.PLACE_TRACKING) {
            if (response.place != null) {
                if (event == PlengiResponse.PlaceEvent.ENTER) {
                    description += "[ENTER]";
                } else if (event == PlengiResponse.PlaceEvent.LEAVE) {
                    description += "[LEAVE]";
                } else if (event == PlengiResponse.PlaceEvent.NEARBY) {
                    description += "[NEARBY]";
                } else {
                    description += "[" + event + "]";
                }
            }
        } else if (response.type == PlengiResponse.ResponseType.LOGGING) {
            description = response.errorReason;
            if (response.place != null) {
                description += response.place.duration_time + ",";
            }
            // (STILL, WALKING, IN_VEHICLE) Activity 관련 로그 일 경우, 현재 기기 위치를 확인하기 위해서 response type 변경(테스트용)
            if (description.contains("[Activity]")) {
                response.type = PlengiResponse.ResponseType.CELL_LOCATION_EVENT;
            }
        } else if (response.type == PlengiResponse.ResponseType.CELL_LOCATION_EVENT) {
            description = "[CELL]";
            PlengiResponse.Location location = response.location;
            if (location != null) {
                description += "(" + location.getLat() + "," + location.getLng() + "," + location.getProvider() + ")";
            }
        } else if (response.type == PlengiResponse.ResponseType.IP_LOC_EVENT) {
            description = "[IPS]";
            PlengiResponse.Location location = response.location;
            if (location != null) {
                description += " " + response.publicIp + ": (" + location.getLat() + "," + location.getLng() + ")";
            }
            if (response.district != null) {
                description += "\n " + response.district.lv1Name + " " + response.district.lv2Name + " " +response.district.lv3Name;
            }
        }

        boolean isLeavePlace = false;
        if (response.place != null) {
            String branch = (response.place.tags == null) ? "" : response.place.tags;
            long loplatid = response.place.loplatid;
            if (event == PlengiResponse.PlaceEvent.LEAVE) {
                if (loplatid == 0) {
                    try {
                        loplatid = Long.parseLong(branch);
                    } catch (Exception e) {
                    }
                }
                description += response.place.name + "," + branch + "(" + loplatid + "), ";
                float minute = (float) response.place.duration_time / 60;
                float hour;
                String duration_time;
                if (minute > 60) {
                    hour = minute / 60;
                    duration_time = String.format("%.1f", hour) + "시간";
                } else {
                    duration_time = String.format("%.1f", minute) + "분";
                }
                description += duration_time;
                isLeavePlace = true;
            } else {
                description += response.place.name + "," + branch + "(" + response.place.loplatid + "), "
                        + response.place.floor + "F, " + String.format("%.3f", response.place.accuracy)
                        + "/" + String.format("%.3f", response.place.threshold);
                if (response.place.client_code != null && !response.place.client_code.isEmpty()) {
                    description += ", code: " + response.place.client_code;
                }
            }
        }
        if (response.area != null) {
            if (response.place != null || response.location != null) {
                description += "\n   ";
            }
            description += "[" + response.area.id + "]" + response.area.name + ","
                    + response.area.tag + "(" + response.area.lat + "," + response.area.lng + ")";
        }
        if (response.complex != null) {
            if (response.place != null) {
                description += "\n   ";
            }
            description += "[" + response.complex.id + "]" + response.complex.name + ","
                    + response.complex.branch_name + "," + response.complex.category;
        }

        if (response.advertisement != null) {
            if (description.length() > 0) {
                description += "\n   ";
            }
            description += "AD)" + response.advertisement.getCampaign_id()
                    + "(" + response.advertisement.getMsg_id() + "):" + response.advertisement.getTitle();
        }

        if (response.geoFence != null) {
            if (description.length() > 0) {
                description += "\n   ";
            }
            description += "GeoFence) " + response.geoFence.toString();
        }

        if (response.location != null && response.type != PlengiResponse.ResponseType.CELL_LOCATION_EVENT
                && response.type != PlengiResponse.ResponseType.IP_LOC_EVENT) {
            if (description.length() > 0) {
                description += "\n   ";
            }
            description += "Location) " + response.location.toString();
        }

        // partner test 일 때 아래 코드 주석 처리 필요
        PlengiResponse.Location placeLocation = null;
        if (response.place != null) {
            PlengiResponse.Place place = response.place;
            placeLocation = new PlengiResponse.Location();
            placeLocation.setLat(place.getLat());
            placeLocation.setLng(place.getLng());
            placeLocation.setProvider("loplat_place");
            //placeLocation.setAccuracy(place.getAccuracy());
        } else if (response.location != null) {
            placeLocation = new PlengiResponse.Location();
            placeLocation.setLat(response.location.getLat());
            placeLocation.setLng(response.location.getLng());
            placeLocation.setProvider("loplat_cps");

        }
        return description;
    }
}
