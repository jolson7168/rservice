#source("/home/ec2-user/git/rservice/src/listener2.R")

library(httpuv)
library(jsonlite)

	.lastMessage <- NULL
app <- list(
	call = function(req) {
		wsUrl = paste(sep='','"',"ws://",ifelse(is.null(req$HTTP_HOST), req$SERVER_NAME, req$HTTP_HOST),'"')
		print(req$REQUEST_METHOD)
		bod <- req[["rook.input"]]
		postdata <- bod$read_lines()
		bodJSON <- fromJSON(postdata)
		bodJSON$status<-paste("Success!")
		list(
			status = 200L,
			headers = list(
				'Content-Type' = 'application/json'
			),
			body = paste(toJSON(bodJSON, pretty=TRUE))
		)
	},

	onWSOpen = function(ws) {
		ws$onMessage(function(binary, message) {
			.lastMessage <<- message
			ws$send(message)
		})
	}
)
server <- runServer("0.0.0.0", 5729, app, interruptIntervalMs = ifelse(interactive(), 100,1000))
print(server)
