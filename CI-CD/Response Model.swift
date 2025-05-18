struct Response: Codable {
    let value: String
}
// https://appstoreconnect.apple.com/analytics/api/v1/data/app-list

//{
//    "size": 7,
//    "results": [
//        {
//            "adamId": "1639409934",
//            "startTime": "2005-05-08T00:00:00Z",
//            "endTime": "2015-04-01T00:00:00Z",
//            "data": {
//                "sessions": {
//                    "previousValue": 0,
//                    "value": 3999,
//                    "percentChange": 0
//                },
//                "proceeds": {
//                    "previousValue": 0,
//                    "value": 0,
//                    "percentChange": 0
//                },
//                "totalDownloads": {
//                    "previousValue": 0,
//                    "value": 571,
//                    "percentChange": 0
//                },
//                "crashes": {
//                    "previousValue": 0,
//                    "value": 32,
//                    "percentChange": 0
//                },
//                "impressionsTotal": {
//                    "previousValue": 0,
//                    "value": 181192,
//                    "percentChange": 0
//                }
//            },
//            "meetsThreshold": true
//        },
//        {
//            "adamId": "6624303981",
//            "startTime": "2005-05-08T00:00:00Z",
//            "endTime": "2015-04-01T00:00:00Z",
//            "data": {
//                "sessions": {
//                    "previousValue": 0,
//                    "value": 1578,
//                    "percentChange": 0
//                },
//                "proceeds": {
//                    "previousValue": 0,
//                    "value": 0,
//                    "percentChange": 0
//                },
//                "totalDownloads": {
//                    "previousValue": 0,
//                    "value": 995,
//                    "percentChange": 0
//                },
//                "crashes": {
//                    "previousValue": 0,
//                    "value": 10,
//                    "percentChange": 0
//                },
//                "impressionsTotal": {
//                    "previousValue": 0,
//                    "value": 42959,
//                    "percentChange": 0
//                }
//            },
//            "meetsThreshold": true
//        },
//        {
//            "adamId": "6636466492",
//            "startTime": "2005-05-08T00:00:00Z",
//            "endTime": "2015-04-01T00:00:00Z",
//            "data": {
//                "sessions": {
//                    "previousValue": 0,
//                    "value": 738,
//                    "percentChange": 0
//                },
//                "proceeds": {
//                    "previousValue": 0,
//                    "value": 1,
//                    "percentChange": 0
//                },
//                "totalDownloads": {
//                    "previousValue": 0,
//                    "value": 688,
//                    "percentChange": 0
//                },
//                "crashes": {
//                    "previousValue": 0,
//                    "value": 0,
//                    "percentChange": 0
//                },
//                "impressionsTotal": {
//                    "previousValue": 0,
//                    "value": 11661,
//                    "percentChange": 0
//                }
//            },
//            "meetsThreshold": true
//        },
//        {
//            "adamId": "6502962295",
//            "startTime": "2005-05-08T00:00:00Z",
//            "endTime": "2015-04-01T00:00:00Z",
//            "data": {
//                "sessions": {
//                    "previousValue": 0,
//                    "value": 0,
//                    "percentChange": 0
//                },
//                "proceeds": {
//                    "previousValue": 0,
//                    "value": 1,
//                    "percentChange": 0
//                },
//                "totalDownloads": {
//                    "previousValue": 0,
//                    "value": 16,
//                    "percentChange": 0
//                },
//                "crashes": {
//                    "previousValue": 0,
//                    "value": 0,
//                    "percentChange": 0
//                },
//                "impressionsTotal": {
//                    "previousValue": 0,
//                    "value": 3231,
//                    "percentChange": 0
//                }
//            },
//            "meetsThreshold": true
//        },
//        {
//            "adamId": "6504800979",
//            "startTime": "2005-05-08T00:00:00Z",
//            "endTime": "2015-04-01T00:00:00Z",
//            "data": {
//                "sessions": {
//                    "previousValue": 0,
//                    "value": 520,
//                    "percentChange": 0
//                },
//                "proceeds": {
//                    "previousValue": 0,
//                    "value": 5,
//                    "percentChange": 0
//                },
//                "totalDownloads": {
//                    "previousValue": 0,
//                    "value": 291,
//                    "percentChange": 0
//                },
//                "crashes": {
//                    "previousValue": 0,
//                    "value": 0,
//                    "percentChange": 0
//                },
//                "impressionsTotal": {
//                    "previousValue": 0,
//                    "value": 14019,
//                    "percentChange": 0
//                }
//            },
//            "meetsThreshold": true
//        },
//        {
//            "adamId": "6736841839",
//            "startTime": "2005-05-08T00:00:00Z",
//            "endTime": "2015-04-01T00:00:00Z",
//            "data": {
//                "sessions": {
//                    "previousValue": 0,
//                    "value": 73,
//                    "percentChange": 0
//                },
//                "proceeds": {
//                    "previousValue": 0,
//                    "value": 0,
//                    "percentChange": 0
//                },
//                "totalDownloads": {
//                    "previousValue": 0,
//                    "value": 125,
//                    "percentChange": 0
//                },
//                "crashes": {
//                    "previousValue": 0,
//                    "value": 0,
//                    "percentChange": 0
//                },
//                "impressionsTotal": {
//                    "previousValue": 0,
//                    "value": 8089,
//                    "percentChange": 0
//                }
//            },
//            "meetsThreshold": true
//        },
//        {
//            "adamId": "6740754881",
//            "startTime": "2005-05-08T00:00:00Z",
//            "endTime": "2015-04-01T00:00:00Z",
//            "data": {
//                "sessions": {
//                    "previousValue": 0,
//                    "value": 38,
//                    "percentChange": 0
//                },
//                "proceeds": {
//                    "previousValue": 0,
//                    "value": 0,
//                    "percentChange": 0
//                },
//                "totalDownloads": {
//                    "previousValue": 0,
//                    "value": 16,
//                    "percentChange": 0
//                },
//                "crashes": {
//                    "previousValue": 0,
//                    "value": 0,
//                    "percentChange": 0
//                },
//                "impressionsTotal": {
//                    "previousValue": 0,
//                    "value": 8437,
//                    "percentChange": 0
//                }
//            },
//            "meetsThreshold": true
//        }
//    ]
//}
