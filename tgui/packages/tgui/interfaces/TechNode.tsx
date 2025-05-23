import type { BooleanLike } from 'common/react';
import { useBackend } from 'tgui/backend';
import { Button, LabeledList, Section, Stack } from 'tgui/components';
import { Window } from 'tgui/layouts';

type Tech = { content: string; color: string; icon: string; tooltip: string };

type Data = {
  theme: string;
  name: string;
  desc: string;
  total_points: number;
  valid_tier: BooleanLike;
  can_afford: BooleanLike;
  unlocked: BooleanLike;
  cost: number;
  stats?: Tech[];
};

export const TechNode = (props) => {
  const { act, data } = useBackend<Data>();

  const {
    total_points,
    can_afford,
    valid_tier,
    unlocked,
    theme,
    cost,
    name,
    desc,
    stats,
  } = data;

  return (
    <Window width={500} height={300} theme={theme}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <Section
              title="Information"
              fill
              buttons={
                <Button backgroundColor="transparent">
                  {'Tech points: ' + total_points}
                </Button>
              }
            >
              <LabeledList>
                <LabeledList.Item label="Name">{name}</LabeledList.Item>
                <LabeledList.Item label="Description">{desc}</LabeledList.Item>
                <LabeledList.Item label="Cost">{cost}</LabeledList.Item>

                {!!stats && (
                  <LabeledList.Item label="Statistics">
                    {stats.map((stat, i) => (
                      <Button
                        key={i}
                        color={stat.color}
                        icon={stat.icon}
                        tooltip={stat.tooltip}
                        mr="100%"
                      >
                        {stat.content}
                      </Button>
                    ))}
                  </LabeledList.Item>
                )}
              </LabeledList>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section>
              <Button
                color="green"
                textAlign="center"
                width="100%"
                p=".5rem"
                disabled={!can_afford || !valid_tier || unlocked ? true : false}
                tooltip={
                  unlocked
                    ? 'Already unlocked'
                    : !valid_tier
                      ? 'Tech tier not unlocked'
                      : !can_afford
                        ? 'Not enough tech points'
                        : ''
                }
                onClick={() => act('purchase')}
              >
                Purchase
              </Button>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
