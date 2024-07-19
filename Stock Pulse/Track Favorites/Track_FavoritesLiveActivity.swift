//
//  Track_FavoritesLiveActivity.swift
//  Track Favorites
//
//  Created by Abhay Limaye on 17-07-2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct Track_FavoritesAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct Track_FavoritesLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: Track_FavoritesAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension Track_FavoritesAttributes {
    fileprivate static var preview: Track_FavoritesAttributes {
        Track_FavoritesAttributes(name: "World")
    }
}

extension Track_FavoritesAttributes.ContentState {
    fileprivate static var smiley: Track_FavoritesAttributes.ContentState {
        Track_FavoritesAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: Track_FavoritesAttributes.ContentState {
         Track_FavoritesAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: Track_FavoritesAttributes.preview) {
   Track_FavoritesLiveActivity()
} contentStates: {
    Track_FavoritesAttributes.ContentState.smiley
    Track_FavoritesAttributes.ContentState.starEyes
}
