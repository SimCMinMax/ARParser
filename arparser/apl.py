# -*- coding: utf-8 -*-
"""
Define the APL class to represent and parse a simc profile.

@author: skasch
"""

from collections import OrderedDict
from .actions import ActionList, PrecombatAction
from .units import Player, Target
from .context import Context
from .helpers import indent
from .constants import IGNORED_ACTION_LISTS
from .database import CLASS_SPECS, TEMPLATES


class APL:
    """
    The main class representing an Action Priority List (or simc profile),
    extracted from its simc string.
    """

    DEFAULT_TEMPLATE = ('{context}'
                        '--- ======= ACTION LISTS =======\n'
                        'local function {function_name}()\n'
                        '  UpdateRanges()\n'
                        '{action_lists}\n'
                        '{precombat_call}\n'
                        '{main_actions}\n'
                        'end\n'
                        '\n{set_apl}')

    def __init__(self):
        self.simc_lines = []
        self.player = None
        self.target = Target()
        self.profile_name = ''
        self.parsed = True
        self.apl_simc = ''
        self.show_comments = True
        self.action_lists_simc = OrderedDict()
        self.context = Context()

    def hide_simc_comments(self):
        """
        Hide the default commented simc lines to the printed lua code.
        """
        self.show_comments = False

    def set_simc_lines(self, simc_lines):
        """
        Set the simc_lines attribute of the object to the content of the
        variable simc_lines.
        """
        self.simc_lines = [simc_line for simc_line in simc_lines
                           if not simc_line.startswith('#')]
        self.parsed = False

    def read_profile(self, file_path):
        """
        Read a .simc profile file.
        """
        with open(file_path, 'r') as profile:
            self.set_simc_lines([line.strip() for line in profile.readlines()])

    def read_string(self, multiline_simc):
        """
        Read a simc profile from a multiline string.
        """
        self.set_simc_lines(multiline_simc.split('\n'))

    def process_lua(self):
        """
        Parse the profile read from the simc_lines attribute and print the lua
        code generated by the profile.
        """
        self.parse_profile()
        return self.print_lua()

    def export_lua(self, file_path):
        """
        Parse the profile read from the simc_lines attribute and export the lua
        code generated into file_path.
        """
        self.parse_profile()
        with open(file_path, 'w') as lua_file:
            lua_file.write(self.print_lua())

    def parse_profile(self):
        """
        Parse the profile from the simc_lines attribute.
        """
        if not self.parsed:
            for simc in self.simc_lines:
                self.parse_line(simc)
            self.parsed = True

    def parse_action(self, simc):
        """
        Parse a single line from the simc_lines attribute if this line is an
        action and append it in its action_list in action_lists_simc dict.
        """
        equal_index = simc.find('+=')
        equal_len = 2
        if equal_index == -1:
            equal_index = simc.find('=')
            equal_len = 1
        if equal_index == -1:
            return
        action_call = simc[:equal_index]
        action_simc = simc[equal_index + equal_len:]
        if '.' not in action_call:
            self.apl_simc += action_simc
            return
        action_name = action_call.split('.')[1]
        if action_name not in IGNORED_ACTION_LISTS:
            if action_name in self.action_lists_simc:
                self.action_lists_simc[action_name] += action_simc
            else:
                self.action_lists_simc[action_name] = action_simc

    def precombat_action(self):
        """
        Get the call to precombat actions.
        """
        return PrecombatAction(self)

    def main_action_list(self):
        """
        Get the ActionList object for the main action list.
        """
        return ActionList(self, self.apl_simc, 'APL')

    def action_lists(self):
        """
        Get the list of ActionList objects from action_lists_simc.
        """
        return [ActionList(self, simc, name)
                for name, simc in self.action_lists_simc.items()]

    def parse_line(self, simc):
        """
        Parse a single line in simc_lines.
        """
        if any(simc.startswith(class_) for class_ in CLASS_SPECS):
            class_, profile_name = simc.split('=')
            self.set_player(class_)
            self.set_profile_name(profile_name)
        elif simc.startswith('spec'):
            _, spec = simc.split('=')
            self.player.set_spec(spec)
        elif simc.startswith('level'):
            _, level = simc.split('=')
            self.player.set_level(level)
        elif simc.startswith('race'):
            _, race = simc.split('=')
            self.player.set_race(race)
        elif simc.startswith('actions'):
            self.parse_action(simc)

    def set_profile_name(self, simc):
        """
        Set the profile name.
        """
        self.profile_name = simc.replace('"', '')

    def set_player(self, simc):
        """
        Set a player as the main actor of the APL.
        """
        self.player = Player(simc, self)
        self.context.set_player(self.player)

    def set_target(self, simc):
        """
        Set the target of the main actor of the APL.
        """
        self.target = Target(simc)

    def print_action_lists_lua(self):
        """
        Print the lua string of the APL.
        """
        return '\n'.join(indent(action_list.print_lua())
                         for action_list in self.action_lists())

    def print_set_apl(self):
        """
        Print the call to SetAPL to set the APL into AR.
        """
        class_simc = self.player.class_.simc
        spec_simc = self.player.spec.simc
        apl_id = CLASS_SPECS.get(class_simc, {}).get(spec_simc, 0)
        return f'AR.SetAPL({apl_id}, APL)\n'
    
    def template(self):
        return TEMPLATES.get(self.player.class_.simc, self.DEFAULT_TEMPLATE)

    def print_lua(self):
        """
        Print the lua string representing the action list.
        """
        function_name = self.main_action_list().name.lua_name()
        action_lists = self.print_action_lists_lua()
        precombat_call = indent(self.precombat_action().print_lua())
        main_actions = self.main_action_list().print_actions_lua()
        context = self.context.print_lua()
        set_apl = self.print_set_apl()
        return self.template().format(
            context=context,
            function_name=function_name,
            action_lists=action_lists,
            precombat_call=precombat_call,
            main_actions=main_actions,
            set_apl=set_apl
        )
