from django.urls import path
from . import views

urlpatterns = [
	path('home', views.home),
	path('phase', views.phase),
	path('about', views.about),
	path('example',views.example),
]

