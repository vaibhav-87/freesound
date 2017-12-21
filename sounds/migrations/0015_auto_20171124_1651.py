# -*- coding: utf-8 -*-
# Generated by Django 1.11 on 2017-11-24 16:51
from __future__ import unicode_literals

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('sounds', '0014_auto_20171124_1628'),
    ]

    operations = [
        migrations.AlterField(
            model_name='sound',
            name='pack',
            field=models.ForeignKey(blank=True, default=None, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='sounds', to='sounds.Pack'),
        ),
    ]