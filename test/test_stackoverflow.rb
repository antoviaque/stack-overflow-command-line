# Copyright (C) 2012 Xavier Antoviaque <xavier@antoviaque.org>
#
# This software's license gives you freedom; you can copy, convey,
# propagate, redistribute and/or modify this program under the terms of
# the GNU Affero General Public License (AGPL) as published by the Free
# Software Foundation (FSF), either version 3 of the License, or (at your
# option) any later version of the AGPL published by the FSF.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero
# General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program in a file in the toplevel directory called
# "AGPLv3".  If not, see <http://www.gnu.org/licenses/>.
#

require 'test/unit'
require 'stackoverflow'
require 'stringio'

class StackOverflowTest < Test::Unit::TestCase

    def test_arguments_empty
        ARGV.clear
        output = capture_stdout { StackOverflow::Command.new.run }
        assert_match /^\*\* Usage: so/, output
    end

    def test_arguments_help
        ARGV.clear
        ARGV << '-h'
        output = capture_stdout { StackOverflow::Command.new.run }
        assert_match /^\*\* Usage: so/, output
        
        ARGV.clear
        ARGV << '--help'
        output = capture_stdout { StackOverflow::Command.new.run }
        assert_match /^\*\* Usage: so/, output
    end

    def test_arguments_unknown
        ARGV.clear
        ARGV << '-sdkjflksd'
        raised_exception = false
        begin
            StackOverflow::Command.new.run
        rescue OptionParser::InvalidOption => e
            assert_match /invalid option: -sdkjflksd/, e.message
            raised_exception = true
        end
        assert_equal raised_exception, true
    end

    def capture_stdout
      previous_stdout, $stdout = $stdout, StringIO.new
      yield
      $stdout.string
    ensure
      $stdout = previous_stdout
    end

end
