
from django.urls import path, include
from django.contrib.auth import get_user_model

from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from rest_framework import serializers, status


from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import permissions


class IsSelf(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        return request.user == obj


class IsSuperAdmin(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user and request.user.is_superuser


class IsManager(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user and request.user.is_staff


class IsGuest(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user and not (request.user.is_superuser or request.user.is_staff)


class CurrentUser(APIView):
    # permission_classes = [IsManager]
    #
    # def get_permissions(self):
    #     return [IsSuperAdmin()] if self.request.method == 'GET' else [IsGuest()]

    class CurrentUserSerializer(serializers.ModelSerializer):
        class Meta:
            model = get_user_model()
            fields = '__all__'

    def get(self, request):
        try:
            serializer = self.CurrentUserSerializer(request.user)
            return Response(serializer.data)
        except serializers.ValidationError as ex:
            return Response(
                {'error': 'Invalid data', 'details': ex.detail},
                status=status.HTTP_400_BAD_REQUEST
            )
        except Exception as ex:
            return Response(
                {'error': str(ex)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class UpdateOwnProfile(APIView):
    permission_classes = [IsSelf]
    pass


urlpatterns = [
    path('token/', include([
        path('', TokenObtainPairView.as_view(), name='token_obtain_pair'),
        path('refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    ])),
    path('user/', include([
        path('me/', include([
            path('', CurrentUser.as_view(), name='current_user'),
        ])),
    ]))
]
