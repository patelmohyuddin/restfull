
import ballerina/http;
import ballerina/log;

listener http:Listener httpListener = new(9090);


map<json> ordersMap = {};

// RESTful service.
@http:ServiceConfig { basePath: "/ordermgt" }
service orderMgt on httpListener {

    
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/order/{orderId}"
    }
    resource function findOrder(http:Caller caller, http:Request req, string orderId) {
       
        json? payload = ordersMap[orderId];
        http:Response response = new;
        if (payload == null) {
            payload = "Order : " + orderId + " cannot be found.";
        }

        
        response.setJsonPayload(untaint payload);

       
        var result = caller->respond(response);
        if (result is error) {
            log:printError("Error sending response", err = result);
        }
    }

   
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/order"
    }
    resource function addOrder(http:Caller caller, http:Request req) {
        http:Response response = new;
        var orderReq = req.getJsonPayload();
        if (orderReq is json) {
            string orderId = orderReq.Order.ID.toString();
            ordersMap[orderId] = orderReq;

            
            json payload = { status: "Order Created.", orderId: orderId };
            response.setJsonPayload(untaint payload);

           
            response.statusCode = 201;
            
            response.setHeader("Location", "http://localhost:9090/ordermgt/order/" +
                    orderId);

          
            var result = caller->respond(response);
            if (result is error) {
                log:printError("Error sending response", err = result);
            }
        } else {
            response.statusCode = 400;
            response.setPayload("Invalid payload received");
            var result = caller->respond(response);
            if (result is error) {
                log:printError("Error sending response", err = result);
            }
        }
    }

    // Resource that handles the HTTP PUT requests that are directed to the path
    // '/order/<orderId>' to update an existing Order.
    @http:ResourceConfig {
        methods: ["PUT"],
        path: "/order/{orderId}"
    }
    resource function updateOrder(http:Caller caller, http:Request req, string orderId) {
        var updatedOrder = req.getJsonPayload();
        http:Response response = new;
        if (updatedOrder is json) {
            // Find the order that needs to be updated and retrieve it in JSON format.
            json existingOrder = ordersMap[orderId];

            // Updating existing order with the attributes of the updated order.
            if (existingOrder != null) {
                existingOrder.Order.Name = updatedOrder.Order.Name;
                existingOrder.Order.Description = updatedOrder.Order.Description;
                ordersMap[orderId] = existingOrder;
            } else {
                existingOrder = "Order : " + orderId + " cannot be found.";
            }
            // Set the JSON payload to the outgoing response message to the client.
            response.setJsonPayload(untaint existingOrder);
            // Send response to the client.
            var result = caller->respond(response);
            if (result is error) {
                log:printError("Error sending response", err = result);
            }
        } else {
            response.statusCode = 400;
            response.setPayload("Invalid payload received");
            var result = caller->respond(response);
            if (result is error) {
                log:printError("Error sending response", err = result);
            }
        }
    }

    
    @http:ResourceConfig {
        methods: ["DELETE"],
        path: "/order/{orderId}"
    }
    resource function cancelOrder(http:Caller caller, http:Request req, string orderId) {
        http:Response response = new;
        
        _ = ordersMap.remove(orderId);

        json payload = "Order : " + orderId + " removed.";
       
        response.setJsonPayload(untaint payload);

       
        var result = caller->respond(response);
        if (result is error) {
            log:printError("Error sending response", err = result);
        }
    }
}
