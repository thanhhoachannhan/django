# Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
# choco install make

echo "################################################## == Environment"
# ================================================== #
echo "[SETUP] - env.build"
#pip install --upgrade pip -q
#pip install django==5.0 -q
#pip install pillow==10.0 -q
#pip install gunicorn==20.0 -q
cat <<text >pyproject.toml
[tool.poetry]
name = "project"
version = "0.1.0"
description = "project"
authors = ["Thanh"]


[tool.poetry.dependencies]
python = "^3.11"
django = "^4.0"
pillow = "^10.4.0"
gunicorn = "^22.0.0"
djangorestframework = "^3.15.2"
djangorestframework-simplejwt = "^5.3.1"


[tool.poetry.group.dev.dependencies]
pyclean = "^3.0.0"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
text
poetry install
# ================================================== #
echo "################################################## == Project Init"
# ================================================== #
echo "[INIT] - project.build"
# django-admin startproject project .
mkdir project
mkdir staticfiles
mkdir templates
# ================================================== #
echo "[CODE] - manage.build"
cat <<text >manage.py
import os, sys
from django.core.management import execute_from_command_line


if __name__ == '__main__':
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'project.settings')
    execute_from_command_line(sys.argv)
text
# ================================================== #
echo "[CODE] - wsgi.build"
cat <<text >project/wsgi.py
import os

from django.core.wsgi import get_wsgi_application


os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'project.settings')
application = get_wsgi_application()
text
# ================================================== #
echo "[CODE] - asgi.build"
cat <<text >project/asgi.py
import os

from django.core.asgi import get_asgi_application


os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'project.settings')

application = get_asgi_application()
text
# ================================================== #
echo "[CODE] - settings.build"
cat <<text >project/settings.py
""" Settings """
import os
from pathlib import Path
from datetime import timedelta

from django.utils.translation import gettext_lazy as _

""" Base settings """
BASE_DIR = Path(__file__).resolve().parent.parent
DEBUG=True
SECRET_KEY = 'dovanthanh'
ALLOWED_HOSTS=['*']
ROOT_URLCONF = 'project.urls'
WSGI_APPLICATION = 'project.wsgi.application'
""" APPS """
AUTH_APP = 'authentication'
APPS = [AUTH_APP, 'core']
DJANGO_APPS = [f"django.contrib.{app}" for app in ['admin','auth','contenttypes','sessions','messages','staticfiles']]
THIRTY_APPS = ['rest_framework']
INSTALLED_APPS = DJANGO_APPS + THIRTY_APPS + [app for app in APPS if os.path.exists(BASE_DIR / app)]
if os.path.exists(BASE_DIR / AUTH_APP) and AUTH_APP in APPS:
    AUTH_USER_MODEL = f'{AUTH_APP}.User'
    AUTHENTICATION_BACKENDS = ['authentication.backends.AuthenticationBackend']
""" Media """
MEDIA_URL = '/uploads/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'uploads')
STATIC_URL = 'static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'static')
STATICFILES_DIRS = [os.path.join(BASE_DIR, 'staticfiles')]
""" Templates """
CONTEXT_PROCESSORS = [
    'django.template.context_processors.debug',
    'django.template.context_processors.request',
    'django.contrib.auth.context_processors.auth',
    'django.contrib.messages.context_processors.messages'
]
TEMPLATES = [{
    'BACKEND': 'django.template.backends.django.DjangoTemplates',
    'DIRS': [os.path.join(BASE_DIR, 'templates')],
    'APP_DIRS': True,
    'OPTIONS': {'context_processors': CONTEXT_PROCESSORS,},
}]
""" Databases """
DATABASES = {'default': {'ENGINE': 'django.db.backends.sqlite3','NAME': BASE_DIR / 'db.sqlite3'}}
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
""" Timezone """
USE_TZ = True
USE_L10N = True
TIME_ZONE = 'UTC'
""" Languages """
USE_I18N = True
LANGUAGE_CODE = 'en'
LOCALE_PATHS = [BASE_DIR / 'locale/',]
LANGUAGES = (
    ('en', _('English')),
    ('vi', _('Vietnamese')),
    ('ja', _('Japanese')),
)
if not os.path.exists(BASE_DIR / 'locale'): os.mkdir('locale')
for lang in LANGUAGES:
    if not os.path.exists(BASE_DIR / 'locale' / lang[0]): os.mkdir(BASE_DIR / 'locale' / lang[0])
    if not os.path.exists(BASE_DIR / 'locale' / lang[0] / 'LC_MESSAGES'): os.mkdir(BASE_DIR / 'locale' / lang[0] / 'LC_MESSAGES')
""" Email """
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
EMAIL_BACKEND = 'django.core.mail.backends.filebased.EmailBackend'
EMAIL_FOLDER_NAME = 'emails'
EMAIL_PATH = BASE_DIR / EMAIL_FOLDER_NAME
if not os.path.exists(EMAIL_PATH): os.mkdir(EMAIL_FOLDER_NAME)
if not os.path.exists(EMAIL_PATH/'.gitkeep'):
    f = open(EMAIL_PATH/'.gitkeep', 'w')
    f.close()
""" Middleware """
AUTH_PASSWORD_VALIDATORS = []
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.locale.LocaleMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]
""" Redirect """
LOGIN_URL = 'login'
""" Logging """
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    "formatters": {
        "verbose": {
            "format": "{levelname} {asctime} {module} {process:d} {thread:d} {message}",
            "style": "{",
        },
        "simple": {
            "format": "{levelname} {message}",
            "style": "{",
        },
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'simple'
        },
        'file': {
            'level': 'DEBUG',
            'class': 'logging.FileHandler',
            'filename': 'log.log',
            'formatter': 'verbose'
        },
    },
    'loggers': {
        '': {
            'level': 'DEBUG',
            'handlers': ['console', 'file'],
        },
    },
}
""" RestAPI """
APPEND_SLASH = False
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
    'DEFAULT_PERMISSION_CLASSES': (
        'rest_framework.permissions.IsAuthenticated',
    ),
}
SIMPLE_JWT = {
    "ACCESS_TOKEN_LIFETIME": timedelta(minutes=5000),
    "REFRESH_TOKEN_LIFETIME": timedelta(days=100),
}
""" EOF """
text
# ================================================== #
echo "[CODE] - urls.build"
cat <<text >project/urls.py
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.conf.urls.i18n import i18n_patterns

from core.views import Index


urlpatterns = [
    path('', Index.as_view(), name='index'),
    path('admin/', admin.site.urls),
    path('i18n/', include('django.conf.urls.i18n')),
]
urlpatterns += i18n_patterns(
    *[path(f'{app}/', include(f'{app}.urls')) for app in settings.APPS],
    prefix_default_language = False
)
urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
text
# ================================================== #
echo "################################################## == Auth app"
# ================================================== #
echo "[INIT] - app.build"
python3 manage.py startapp authentication
mkdir authentication/templates
# ================================================== #
echo "[CODE] - authentication.models.build"
cat <<text >authentication/models.py
from django.db import models
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin, UserManager, Permission, GroupManager
from django.contrib.auth.validators import UnicodeUsernameValidator
from django.utils import timezone
from django.utils.translation import gettext_lazy as _

class UserGroup(models.Model):
    name = models.CharField(_('name'), max_length=150, unique=True)
    permissions = models.ManyToManyField(
        Permission,
        verbose_name=_('permissions'),
        blank=True,
    )

    objects = GroupManager()

    class Meta:
        verbose_name = _('group')
        verbose_name_plural = _('groups')

    def __str__(self):
        return self.name

    def natural_key(self):
        return (self.name,)


class User(AbstractBaseUser, PermissionsMixin):
    username = models.CharField(_('username'), max_length=101, unique=True, validators=[UnicodeUsernameValidator()])
    fullname = models.CharField(_('fullname'), max_length=100)
    email = models.EmailField(_('email'))
    avatar = models.ImageField(_('avatar'), upload_to='avatar')
    address = models.TextField(_('address'))
    is_staff = models.BooleanField(_('is_staff'), default=False)
    is_active = models.BooleanField(_('is_active'), default=True)
    date_joined = models.DateTimeField(_('date_joined'), default=timezone.now)
    groups = models.ManyToManyField(UserGroup, verbose_name=_('groups'), blank=True)

    objects = UserManager()

    EMAIL_FIELD = 'email'
    USERNAME_FIELD = 'username'
    # REQUIRED_FIELDS = ['email']

    def __str__(self):
        return f'{self.fullname}({self.username})'

    class Meta:
        verbose_name = _('user')
        verbose_name_plural = _('users')
text
# ================================================== #
echo "[CODE] - authentication.signals.build"
cat <<text >authentication/signals.py
from django.contrib.auth.signals import user_logged_in, user_login_failed, user_logged_out
from django.dispatch import receiver
import logging


logger = logging.getLogger('django')

@receiver(user_logged_in)
def post_login(sender, request, user, **kwargs):
    logger.info(f'User: {user.username} logged in')

@receiver(user_logged_out)
def post_logout(sender, request, user, **kwargs):
    logger.info(f'User: {user.username} logged out')

@receiver(user_login_failed)
def post_login_fail(sender, credentials, request, **kwargs):
    logger.info(f'Login failed with credentials: {credentials}')
text
# ================================================== #
echo "[CODE] - authentication.apps.build"
cat <<text >authentication/apps.py
from django.apps import AppConfig


class AuthenticationConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'authentication'

    def ready(self):
        import authentication.signals
text
# ================================================== #
echo "[CODE] - authentication.admin.build"
cat <<text >authentication/admin.py
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin, GroupAdmin
from django.contrib.auth.models import Group
from django.utils.translation import gettext_lazy as _

from authentication.models import User, UserGroup


@admin.register(User)
class UserAdmin(UserAdmin):
    fieldsets = (
        (None, {
            'fields': ('username', 'password', 'fullname', 'email', 'avatar', 'address', 'groups')
        }),
        ('Advanced options', {
            'classes': ('collapse'),
            'fields': ('user_permissions', 'is_active', 'is_staff', 'is_superuser')
        })
    )
    list_display = ('username', 'email', 'date_joined')
    list_filter = ('is_staff', 'is_active')
    search_fields = ('username__startswith', 'fullname__startswith')

    class Meta:
        ordering = ('date_joined')


admin.site.unregister(Group)
@admin.register(UserGroup)
class CustomGroupAdmin(GroupAdmin):
    fieldsets = (
        (None, {'fields': ('name', 'permissions')}),
    )
text
# ================================================== #
echo "[CODE] - authentication.backends.build"
cat <<text >authentication/backends.py
from django.contrib.auth import get_user_model
from django.contrib.auth.backends import ModelBackend

User=get_user_model()

class AuthenticationBackend(ModelBackend):
    def authenticate(self, request, username=None, password=None, **kwargs):
        try:
            user = User.objects.get(username=username)
        except User.DoesNotExist:
            return None

        if user.check_password(password):
            return user

    def get_user(self, user_id):
        try:
            return User.objects.get(pk=user_id)
        except User.DoesNotExist:
            return None
text
# ================================================== #
echo "[CODE] - authentication.forms.build"
cat <<text >authentication/forms.py
from django import forms
from django.contrib.auth.forms import AuthenticationForm
from django.contrib.auth import get_user_model
from django.core import exceptions
from django.utils.translation import gettext_lazy as _


class LoginForm(AuthenticationForm):
    error_messages = { 'invalid_login': _('Invalid login'), 'inactive': _('Inactive'), }
    def confirm_login_allowed(self, user):
        if not user.is_active: raise exceptions.ValidationError(_('User inactive'), code='inactive')
text
# ================================================== #
echo "[CODE] - authentication.views.build"
cat <<text >authentication/views.py
from django.shortcuts import render, redirect
from django.contrib.auth import login, logout, authenticate
from django.urls import reverse
from django.views import View
from django.contrib.auth.mixins import LoginRequiredMixin

from authentication.forms import LoginForm


class Login(View):
    def get(self, request):
        if request.user.is_authenticated:
            return redirect(reverse('core:index'))
        return render(request, 'login.html', {
            'form': LoginForm()
        })
    def post(self, request):
        form = LoginForm(request, data=request.POST)
        if form.is_valid():
            username = form.cleaned_data.get('username')
            password = form.cleaned_data.get('password')
            print(username)
            user = authenticate(request, username=username, password=password)
            if user is not None:
                login(request, user)
                next_url = request.GET.get('next', 'core:index')
                return redirect(next_url)
        else:
            print('form is not valid')
            print(form.error_messages)
        return render(request, 'login.html')

class Logout(LoginRequiredMixin, View):
    def get(self, request):
        logout(request)
        next_url = request.GET.get('next', '/')
        return redirect(next_url)
text
# ================================================== #
echo "[CODE] - authentication.api.build"
cat <<text >authentication/api.py
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

    def get_permissions(self):
        return [IsSuperAdmin()] if self.request.method == 'GET' else [IsGuest()]

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
text
# ================================================== #
echo "[CODE] - authentication.urls.build"
cat <<text >authentication/urls.py
from django.urls import path, include
from authentication.views import Login, Logout


app_name = 'authentication'

urlpatterns = [
    path('login', Login.as_view(), name='login'),
    path('logout', Logout.as_view(), name='logout'),
    path('api', include('authentication.api')),
]
text
# ================================================== #
echo "[CODE] - authentication.templates.login.build"
cat <<HTML >authentication/templates/login.html
{% load i18n %}
<form method="post"> {% csrf_token %} {{ form }} <input type="submit" value="login"/> </form>
HTML
# ================================================== #
echo "################################################## == Core app"
# ================================================== #
echo "[INIT] - app.build"
python3 manage.py startapp core
mkdir core/templates
# ================================================== #
echo "[CODE] - core.admin.build"
cat <<text >core/admin.py
from django.apps import apps
from django.contrib import admin
from django.contrib.admin.sites import AlreadyRegistered


for model in apps.get_app_config('core').get_models():
    try: admin.site.register(model)
    except AlreadyRegistered: pass
text
# ================================================== #
echo "[CODE] - core.views.build"
cat <<text >core/views.py
from django.shortcuts import render
from django.views import View


class Index(View):
    def get(self, request):
        return render(request, 'index.html')
text
# ================================================== #
echo "[CODE] - core.urls.build"
cat <<text >core/urls.py
from django.urls import path
from core.views import Index


app_name = 'core'

urlpatterns = [
    path('index', Index.as_view(), name='index'),
]
text
# ================================================== #
echo "[CODE] - core.templates.index.build"
cat <<HTML >core/templates/index.html
Core
HTML
# ================================================== #
echo "################################################## == Common Template"
# ================================================== #
mkdir staticfiles/css
cat <<text >staticfiles/css/main.css
text
# ================================================== #
mkdir staticfiles/js
cat <<text >staticfiles/js/main.js
text
# ================================================== #
echo "################################################## == Makefile"
# ================================================== #
echo "[CODE] - makefile.build"
cat <<text >makefile
all:
	rm -fr migrations
	rm -fr db.sqlite3
	python3 manage.py makemigrations core authentication ecommerce
	python3 manage.py migrate
	python3 manage.py shell -c "from django.contrib.auth import get_user_model; get_user_model().objects.filter(username='admin').exists() or get_user_model().objects.create_superuser('admin', 'admin@admin.com', 'admin')"
	python3 manage.py runserver 2000
up:
	python3 manage.py runserver 2000
clear:
	find . -mindepth 1 -not -name 'build.sh' -delete
text
# ================================================== #
echo "################################################## == Migrate"
# ================================================== #
echo "[INFO] - collectstatic"
python3 manage.py collectstatic --no-input > /dev/null 2>&1
echo "[INFO] - migrate"
python3 manage.py makemigrations core authentication > /dev/null 2>&1
python3 manage.py migrate > /dev/null 2>&1
echo "[INFO] - superuser.create"
python3 manage.py shell -c "from django.contrib.auth import get_user_model; get_user_model().objects.filter(username='admin').exists() or get_user_model().objects.create_superuser('admin', 'admin@admin.com', 'admin');"
# ================================================== #
