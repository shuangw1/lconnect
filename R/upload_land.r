#' upload_land
#' @title Import and convert a shapefile to a lconnect object
#' @description Import and convert a shapefile to a lconnect object. Some
#' landscape and patch metrics which are the core of landscape connectivity
#' metrics are calculated. The shapefile must be projected, i.e., in planar 
#' coordinates and the first field must be contain the habitat categories.
#' @param land_path string, indicating the full path of the landscape shapefile.
#' @param bound_path string, indicating the full path of the boundary shapefile.
#' If NULL (default option) a convex hull will be created and used as boundary.
#' @param habitat vector with habitat categories. The categories can be numeric
#' or character.
#' @param min_dist numeric indicating the minimum distance to aggregate patches. 
#' @usage upload_land(land_path, bound_path = NULL, habitat, min_dist = NULL)
#' @return A lconnect object is returned.
#' @examples vec_path <- system.file("extdata/vec_projected.shp", package = "lconnect")
#' landscape <- upload_land(vec_path, bound_path = NULL,
#' habitat = 1, min_dist = 500)
#' plot(landscape)
#' @author Bruno Silva
#' @author Frederico Mestre
#' @export
#' @exportClass lconnect
upload_land <- function(land_path, bound_path = NULL, habitat, min_dist = NULL){
  landscape <- sf::st_read(land_path, quiet = T)
  landscape <- landscape[landscape[[1]] == habitat,]
  landscape <- sf::st_union(landscape)
  if(is.null(bound_path)){
    boundary <- sf::st_convex_hull(landscape)
  } else{
    boundary <- sf::st_read(bound_path, quiet = T)
  }
  area_l <- sf::st_area(boundary)
  landscape <- sf::st_cast(landscape, "POLYGON")
  distance <- sf::st_distance(landscape)
  distance <- stats::as.dist(distance)
  aux <- component_calc(landscape, distance, min_dist)
  landscape <- suppressWarnings(sf::st_sf(clusters = aux$clusters, 
                                      geometry = landscape))
  object <- list(landscape = landscape, min_dist = min_dist, 
                 clusters = aux$clusters, distance = distance, 
                 boundary = boundary, area_l = area_l)
  class(object) <- "lconnect"
  return(object)
}
